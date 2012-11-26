require 'flex'
require 'flex-backup'

env   = defined?(Rails) ? :environment : []
tasks = Flex::Backup::Tasks.new

namespace :flex do

  desc 'Dumps the data from one or more ElasticSearch indices to a file'
  task(:dump => env) { tasks.dump_to_file }

  desc 'Loads a dumpfile into ElasticSearch'
  task(:load => env) { tasks.load_from_file }

  desc 'dump, re-create the index and load the data again'
  task(:reindex => env) do
    require 'tempfile'
    begin
      tempfile = Tempfile.new %w[flex-backup dump], :encoding => 'UTF-8'
      tasks.options[:file] = tempfile
      tasks.dump_to_file

      Flex::Tasks.new(:force => true).create_indices

      tempfile.open
      tasks.load_from_file
    ensure
      tempfile.close
      tempfile.unlink
    end
  end

end
