Barista::Framework.register 'jmvc', Rails.root.join("public", "dreamcatcher")
# Barista::Framework.register 'backbone', Rails.root.join("public", "backbone")

Barista.configure do |c|
  
  # Change the root to use app/scripts
  
  c.root = Rails.root.join("app", "coffee")
  # c.root = Rails.root.join("public", "dreamcatcher", "coffee")
  
  c.output_root = Rails.root.join("public", "javascripts", "compiled")
  # c.output_root = Rails.root.join("public", "dreamcatcher")

  c.embedded_interpreter = false
  # Set the compiler
  
  # Disable wrapping in a closure:
  # c.no_wrap = true
  # ... or ...
  # c.no_wrap!
  
  # Change the output root for a framework:
  
  c.change_output_root! 'jmvc', 'public/compiled'
  c.change_output_root! 'backbone', 'public/compiled'

  c.bare = true
  
  # or for all frameworks...
  
  # c.each_framework do |framework|
  #   c.change_output_prefix! framework.name, "vendor/#{framework.name}"
  # end
  
  # or, prefix the path for the app files:
  
  # c.change_output_prefix! :default, 'my-app-name'  
  
  # or, hook into the compilation:
  
  # c.before_compilation   { |path|         puts "Barista: Compiling #{path}" }
  # c.on_compilation       { |path|         puts "Barista: Successfully compiled #{path}" }
  # c.on_compilation_error { |path, output| puts "Barista: Compilation of #{path} failed with:\n#{output}" }
  # c.on_compilation_with_warning { |path, output| puts "Barista: Compilation of #{path} had a warning:\n#{output}" }
  
  # Turn off preambles and exceptions on failure
  
  # c.verbose = false
  
  # Or, make sure it is always on
  # c.verbose!
  
  # Changing the compiler
  
  # To use a customer compiler class:
  # c.compiler_klass = MyAwesomeCompilerClass
  # c.compiler = :null # Barista::Compilers::Null
  
  # To switch between the built in compilers:
  # c.compiler = :native
  # or...
  # c.compiler = :node
  
  # The default compiler is auto detected.
  
  # If you want to use a custom JS file, you can as well
  # e.g. vendoring CoffeeScript in your application:
  # c.js_path = Rails.root.join('public', 'javascripts', 'coffee-script.js')
  
end