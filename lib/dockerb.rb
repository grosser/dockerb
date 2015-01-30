require 'erb'

module Dockerb
  class << self
    def compile
      return (yield if block_given?) unless File.exist?("Dockerfile.erb")
      begin
        File.write("Dockerfile", Context.compile(File.read("Dockerfile.erb")))
        yield if block_given?
      ensure
        File.unlink("Dockerfile") if File.exist?("Dockerfile") && block_given?
      end
    end
  end

  class Context
    class << self
      def compile(code)
        ERB.new(code).result(binding)
      end

      private

      def bundle
        <<-EOF.gsub(/^          /, "")
          ADD Gemfile /app/
          ADD Gemfile.lock /app/
          ADD vendor/cache /app/vendor/cache
          RUN bundle install --quiet --local --jobs 4 || bundle check
        EOF
      end

      def install_gem(name)
        version = File.read("Gemfile.lock")[/^    #{name} \((.+)\)/, 1] || raise("Gem #{name} not found in Gemfile.lock")
        "RUN gem install -v #{version} #{name}"
      end
    end
  end
end
