Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "DDColorPicker"
  s.version      = "0.0.1"
  s.summary      = "DDColorPicker is the most beautiful open source color picker"

  s.description  = <<-DESC
                   DDColorPicker is a color picker which allows a developer to integrate
                   a nice circular color palette into their app allowing users to select
                   the color they want to use.

                   Originally it was built for a sketching section of an event app for Tasboa
                   DESC

  s.homepage     = "http://github.com/vascoorey/DDColorPicker"
  # s.screenshots  = "www.example.com/screenshots_1", "www.example.com/screenshots_2"

  s.license       = { :type => 'MIT',
                      :text => %Q|Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n| +
                               %Q|The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n| +
                               %Q|THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE| }    
  s.authors      = { "Vasco Orey" => "vasco@tasboa.com", "Niko Roberts" => "niko@tasboa.com", "Jan Jokela" => "jan@tasboa.com" }

  s.platform     = :ios, '6.0' # autolayout requires
  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source       = { :git => "http://github.com/vascoorey/DDColorPicker.git", :tag => s.version.to_s }
  s.source_files  = 'DDColorPicker/**/*.{h,m}'
  s.dependency 'Masonry', '~> 0.3.0'
  s.frameworks = 'Accelerate.framework'
end
