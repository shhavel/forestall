$log_file = File.new(File.join(settings.root, 'log', "#{settings.environment}.log"), 'a+')
$log_file.sync = true
$logger = Logger.new($log_file).tap { |l| l.formatter = ->(_, _, _, msg) { "#{msg}\n" } }
