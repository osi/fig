# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "fig18"
  s.version = "0.1.39"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthew Foemmel"]
  s.date = "2011-10-20"
  s.description = "Fig is a utility for configuring environments and managing dependencies across a team of developers. You give it a list of packages and a shell command to run; it creates an environment that includes those packages, then executes the shell command in it (the caller's environment is not affected)."
  s.email = "git@foemmel.com"
  s.executables = ["fig", "fig-download"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    "bin/fig",
    "bin/fig-download",
    "lib/fig.rb",
    "lib/fig/backtrace.rb",
    "lib/fig/environment.rb",
    "lib/fig/grammar.treetop",
    "lib/fig/options.rb",
    "lib/fig/os.rb",
    "lib/fig/package.rb",
    "lib/fig/parser.rb",
    "lib/fig/repository.rb",
    "lib/fig/retriever.rb",
    "lib/fig/windows.rb"
  ]
  s.homepage = "http://github.com/mfoemmel/fig"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "Fig is a utility for configuring environments and managing dependencies across a team of developers."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<libarchive-static-ruby186>, ["= 1.0.0"])
      s.add_runtime_dependency(%q<net-ssh>, [">= 2.0.15"])
      s.add_runtime_dependency(%q<net-sftp>, [">= 2.0.4"])
      s.add_runtime_dependency(%q<net-netrc>, [">= 0.2.2"])
      s.add_runtime_dependency(%q<polyglot>, [">= 0.2.9"])
      s.add_runtime_dependency(%q<treetop>, [">= 1.4.2"])
      s.add_runtime_dependency(%q<highline>, [">= 1.6.2"])
      s.add_development_dependency(%q<rspec>, ["~> 2"])
      s.add_development_dependency(%q<open4>, [">= 1.0.1"])
      s.add_runtime_dependency(%q<libarchive-static-ruby186>, ["= 1.0.0"])
      s.add_runtime_dependency(%q<net-ssh>, [">= 2.0.15"])
      s.add_runtime_dependency(%q<net-sftp>, [">= 2.0.4"])
      s.add_runtime_dependency(%q<net-netrc>, [">= 0.2.2"])
      s.add_runtime_dependency(%q<polyglot>, [">= 0.2.9"])
      s.add_runtime_dependency(%q<treetop>, [">= 1.4.2"])
      s.add_runtime_dependency(%q<highline>, [">= 1.6.2"])
      s.add_development_dependency(%q<rspec>, ["~> 2"])
      s.add_development_dependency(%q<open4>, [">= 1.0.1"])
    else
      s.add_dependency(%q<libarchive-static-ruby186>, ["= 1.0.0"])
      s.add_dependency(%q<net-ssh>, [">= 2.0.15"])
      s.add_dependency(%q<net-sftp>, [">= 2.0.4"])
      s.add_dependency(%q<net-netrc>, [">= 0.2.2"])
      s.add_dependency(%q<polyglot>, [">= 0.2.9"])
      s.add_dependency(%q<treetop>, [">= 1.4.2"])
      s.add_dependency(%q<highline>, [">= 1.6.2"])
      s.add_dependency(%q<rspec>, ["~> 2"])
      s.add_dependency(%q<open4>, [">= 1.0.1"])
      s.add_dependency(%q<libarchive-static-ruby186>, ["= 1.0.0"])
      s.add_dependency(%q<net-ssh>, [">= 2.0.15"])
      s.add_dependency(%q<net-sftp>, [">= 2.0.4"])
      s.add_dependency(%q<net-netrc>, [">= 0.2.2"])
      s.add_dependency(%q<polyglot>, [">= 0.2.9"])
      s.add_dependency(%q<treetop>, [">= 1.4.2"])
      s.add_dependency(%q<highline>, [">= 1.6.2"])
      s.add_dependency(%q<rspec>, ["~> 2"])
      s.add_dependency(%q<open4>, [">= 1.0.1"])
    end
  else
    s.add_dependency(%q<libarchive-static-ruby186>, ["= 1.0.0"])
    s.add_dependency(%q<net-ssh>, [">= 2.0.15"])
    s.add_dependency(%q<net-sftp>, [">= 2.0.4"])
    s.add_dependency(%q<net-netrc>, [">= 0.2.2"])
    s.add_dependency(%q<polyglot>, [">= 0.2.9"])
    s.add_dependency(%q<treetop>, [">= 1.4.2"])
    s.add_dependency(%q<highline>, [">= 1.6.2"])
    s.add_dependency(%q<rspec>, ["~> 2"])
    s.add_dependency(%q<open4>, [">= 1.0.1"])
    s.add_dependency(%q<libarchive-static-ruby186>, ["= 1.0.0"])
    s.add_dependency(%q<net-ssh>, [">= 2.0.15"])
    s.add_dependency(%q<net-sftp>, [">= 2.0.4"])
    s.add_dependency(%q<net-netrc>, [">= 0.2.2"])
    s.add_dependency(%q<polyglot>, [">= 0.2.9"])
    s.add_dependency(%q<treetop>, [">= 1.4.2"])
    s.add_dependency(%q<highline>, [">= 1.6.2"])
    s.add_dependency(%q<rspec>, ["~> 2"])
    s.add_dependency(%q<open4>, [">= 1.0.1"])
  end
end

