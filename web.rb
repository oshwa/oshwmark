require 'sinatra'

require 'prawn'
require 'prawn-svg'
require "mini_magick"

get '/' do
  cache_control :public
  haml :index
end

def generate(uid, ext)


  width  = 900
  height = 660
  margin = 42
  font   = "Deja Vu Sans Mono"

  case ext
  when "pdf"
    content_type :pdf
    content_file = "OSHW_mark_#{uid}.pdf"

    Prawn::Document.generate(
      content_file, page_size: [width, height], margin: 0
    ) do |doc|

      doc.font_families.update(
        font => {
          normal: "ext/DejaVuSansMono.ttf",
          bold:   "ext/DejaVuSansMono-Bold.ttf"
        }
      )

      doc.svg IO.read("ext/OSHW_mark.svg"), at: [0, height-margin], width: width

      box_args = {width: width-margin*4, at: [margin*2, doc.cursor-margin], size: 150, align: :center}
      doc.font font
      doc.formatted_text_box [{text: uid, color: '333333'}], box_args
    end

  when "png"
    content_type :png
    content_file = "OSHW_mark_#{uid}.png"

    ## Margin on SVG has to be adjusted a bit to match PDF output
    svg_margin = 45
    svg_width  = width-svg_margin*4
    svg_height = svg_width / 1.92

    MiniMagick::Tool::Convert.new do |cmd|
      cmd.background 'white'
      cmd.density    200
      cmd << "ext/OSHW_mark.svg"

      ## ImageMagick doesn't find the correct size for the SVG so we
      ## have to explicitly set it (ignoring the original aspect ratio)
      cmd.resize  "#{svg_width}x#{svg_height}!"

      ## Resize the image canvas to add the margin around the logo
      cmd.compose 'copy'
      cmd.gravity 'center'
      cmd.extent  "#{width}x#{svg_height + 2*margin}"

      ## Resize the image canvas to add space before the logo for text
      cmd.gravity 'north'
      cmd.extent  "#{width}x#{height}"

      ## Add the UID text
      cmd.font      "ext/DejaVuSansMono.ttf"
      cmd.pointsize 55
      cmd.fill      '#333'
      cmd.gravity   'south'
      cmd.draw      "text 0,#{margin*1.2} \'#{uid}\'"

      cmd << content_file
    end

  end

  content = File.read content_file
  File.delete content_file

  headers \
    "Content-Disposition" => "attachment; filename=#{content_file};",
    "Content-Type" => "application/octet-stream",
    "Content-Transfer-Encoding" => "binary"
  body content
end

post '/mark' do

  country     = params[:country][0..1].upcase
  uid         = "#{country}#{"%06d" % params[:number][0..5].to_i}"

  if params.keys.include? "PDF"
    generate(uid, "pdf")
  elsif params.keys.include? "PNG"
    generate(uid, "png")
  end
end

get '/mark' do
  redirect to('/')
end

get '/mark/:country/:number.:format' do

  unless ["pdf", "png"].include? params[:format].downcase
    return "Unsupported file type"
  end

  country     = params[:country][0..1].upcase
  uid         = "#{country}#{"%06d" % params[:number][0..5].to_i}"

  generate(uid, params[:format].downcase)
end



__END__

@@ layout
!!!
%html
  %head
    %title OSHW Mark Generator
    %link{rel:"stylesheet", href:"https://unpkg.com/purecss@1.0.0/build/pure-min.css", crossorigin:"anonymous"}
    %meta{name:"viewport",content:"width=device-width, initial-scale=1"}
  %body
    = yield

@@ index
#main.pure-g
  .pure-u-1-5
  .pure-u-3-5
    .header
      %h1
        %img{src:"https://www.oshwa.org/wp-content/uploads/2017/03/oshwa-logo-50.png"}
        OSHW Mark Generator

    .content
      %p
      %form{class:"pure-form pure-form-aligned", method:"post", action:"/mark"}
        %fieldset
          .pure-control-group
            %label{for:"country"} Country Code
            %input{name:"country", type:"text"}
            %span{class:"pure-form-message-inline"} This is your 2 letter country code, like 'US'.

          .pure-control-group
            %label{for:"number"} Number
            %input{name:"number", type:"text"}
            %span{class:"pure-form-message-inline"} This is the number from your certification.

          .pure-controls
            %button{type:"submit", class:"pure-button pure-button-primary", name:"PDF"}Generate PDF
            %button{type:"submit", class:"pure-button pure-button-primary", name:"PNG"}Generate PNG

      %p
      %p
        This web service was created by
        %a{href:"http://capablerobot.com"} Capable Robot Components
        to simplify the generation of OSHW marks, after certification is complete.
      %p
        Information about open souce hardware certification is available on the
        %a{href:"https://certification.oshwa.org"} OSHWA Website.
        OSHWA Certification Logo used with permission.
      %p
        If you have suggestions on how to make this tool more useful (or want to talk about robots and OSHW), email us at robot@capablerobot.com
      %p
      %p
        The source code for this service is MIT licensed and is
        %a{href:"https://github.com/CapableRobot/oshwmark"} available on Github.
      %p
        Follow
        %a{href:"https://twitter.com/capablerobot"} Capable Robot on Twitter
        for product announcements and updates.
      %p
      %p
        Thanks!

  .pure-u-1-5


