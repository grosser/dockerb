require "spec_helper"

describe Dockerb do
  it "has a VERSION" do
    Dockerb::VERSION.should =~ /^[\.\da-z]+$/
  end

  around do |test|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir, &test)
    end
  end

  describe ".compile" do
    let(:calls) { [] }

    it "generates a Dockerfile" do
      File.write("Dockerfile", "XXX")
      Dockerb.compile { File.read("Dockerfile") }.should == "XXX"
    end

    it "does nothing if there is no Dockerfile.erb" do
      Dockerb.compile { File.exist?("Dockerfile") }.should == false
    end
  end

  describe Dockerb::Context do
    describe ".compile" do
      def call(*args)
        Dockerb::Context.send(:compile, *args)
      end

      it "compiles plain" do
        call("PLAIN").should == "PLAIN"
      end

      it "compiles simple ruby" do
        call("<%= 'HELLO' %>").should == "HELLO"
      end

      it "can generate bundler template" do
        call("<%= bundle %>").should == <<-EOF.gsub(/^          /, "")
          ADD Gemfile /app/
          ADD Gemfile.lock /app/
          ADD vendor/cache /app/vendor/cache
          RUN (bundle install --quiet --local --jobs 4 || bundle check) && find /usr/local/lib/ruby/gems/*/gems/ -maxdepth 2 -name "ext" -o -name "test" -o -name "spec" | xargs rm -r
        EOF
      end

      it "generates gem install commands" do
        File.write("Gemfile.lock", "  nokogiri (~> 1.2.3)\n      nokogiri (2.3.4)\n    nokogiri (3.4.5)")
        call("<%= install_gem 'nokogiri' %>").should == %{RUN gem install -v 3.4.5 nokogiri && find /usr/local/lib/ruby/gems/*/gems/ -maxdepth 2 -name "ext" -o -name "test" -o -name "spec" | xargs rm -r}
      end

      it "generates gem install command with args" do
        File.write("Gemfile.lock", "  nokogiri (~> 1.2.3)\n      nokogiri (2.3.4)\n    nokogiri (3.4.5)")
        call("<%= install_gem 'nokogiri', '--foobar' %>").should == %{RUN gem install -v 3.4.5 nokogiri --foobar && find /usr/local/lib/ruby/gems/*/gems/ -maxdepth 2 -name "ext" -o -name "test" -o -name "spec" | xargs rm -r}
      end

      it "fails when it cannot find a gem in the Gemfile.lock" do
        File.write("Gemfile.lock", "")
        -> { call("<%= install_gem 'nokogiri' %>") }.should raise_error(RuntimeError)
      end
    end
  end

  describe "CLI" do
    def sh(command, options={})
      result = Bundler.with_clean_env { `#{command} #{"2>&1" unless options[:keep_output]}` }
      raise "#{options[:fail] ? "SUCCESS" : "FAIL"} #{command}\n#{result}" if $?.success? == !!options[:fail]
      result
    end

    def dockerb(command, options={})
      sh("#{Bundler.root}/bin/dockerb #{command}", options)
    end

    it "shows --version" do
      dockerb("--version").should include(Dockerb::VERSION)
    end

    it "shows --help" do
      dockerb("--help").should include("dynamic Dockerfile")
    end

    it "generates a Dockerfile" do
      File.write("Dockerfile.erb", "<%= 1 + 2 %>")
      dockerb("")
      File.read("Dockerfile").should == "3"
    end

    it "is silent without Dockerfile" do
      dockerb("")
      File.exist?("Dockerfile").should == false
    end
  end
end
