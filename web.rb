require 'sinatra'

require 'prawn'
require 'prawn-svg'
require "mini_magick"

get '/' do
  cache_control :public
  haml :index
end

def generate(uid, ext)
  output_file = "OSHW_mark_#{uid}.pdf"

  width  = 300
  height = 220
  margin = 14
  font   = "Deja Vu Sans Mono"

  Prawn::Document.generate(
    output_file, page_size: [width, height], margin: 0
  ) do |doc|

    doc.font_families.update(
      font => {
        normal: "ext/DejaVuSansMono.ttf",
        bold:   "ext/DejaVuSansMono-Bold.ttf"
      }
    )

    doc.svg IO.read("ext/OSHW_logo.svg"), at: [0, height-margin], width: width

    doc.font font
    doc.text_box uid, width: width-margin*2, at: [margin*2, doc.cursor-margin], size: 50
  end

  case ext
  when "pdf"
    content_type :pdf
    content_file = output_file

  when "png"
    content_type :png
    content_file = output_file.gsub(".pdf", ".png")

    pdf = MiniMagick::Image.open(output_file)
    image = pdf.pages[0]
    image.resize "#{width}x#{height}"

    image.combine_options do |c|
      c.background '#FFFFFF'
      c.alpha 'remove'
    end

    image.format "png"
    image.write content_file

    # Delete the PDF, we don't need it anymore
    File.delete output_file
  end

  content = File.read content_file
  File.delete content_file

  headers \
    "Content-Disposition" => "attachment; filename=#{content_file};",
    "Content-Type" => "application/octet-stream",
    "Content-Transfer-Encoding" => "binary"
  body content
end

post '/logo' do

  country     = params[:country][0..1].upcase
  uid         = "#{country}#{"%06d" % params[:number][0..5].to_i}"

  if params.keys.include? "PDF"
    generate(uid, "pdf")
  elsif params.keys.include? "PNG"
    generate(uid, "png")
  end
end

get '/logo' do
  redirect to('/')
end

get '/logo/:country/:number.:format' do

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
      %form{class:"pure-form pure-form-aligned", method:"post", action:"/logo"}
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

        Certification process information is available on the
        %a{href:"https://certification.oshwa.org"} OSHWA Website.
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


