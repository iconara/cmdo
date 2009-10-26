require 'flexutils'


include FlexUtils


ENV['FLEX_HOME'] ||= '/Applications/Adobe Flash Builder Beta/sdks/3.4.0'


task :default => :test

task :test => ['build', 'build/Tests.swf'] do |t|
  Adl.run(t.prerequisites.last) do |conf|
    conf.width  = 400
    conf.height = 250
  end
end

file 'build/Tests.swf' => ['test/Tests.mxml'] + FileList['{test,src}/**/*.as'] do |t|
  Mxmlc.compile(t.name, t.prerequisites.first) do |conf|
    conf.compiler        = 'air'
    conf.debug           = true
    conf.incremental     = true
    conf.source_path     = ['src', 'test']
    conf.library_path    = ['lib']
    conf.target_player   = '10'
    conf.fail_on_warning = true
  end
end

directory 'build'