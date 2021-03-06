require "simplecov"
SimpleCov.start do
  add_filter "/test/"
end

# run tests in production mode so that file digests are enabled
ENV["ENV"] = "production"

# workaround checking. here before loading our application to ensure
# we aren't testing against our own monkeypatches.

describe "date 'now' patch" do
  # if this test fails, the monkey match on StandardFilters#date can be removed
  it "is necessary" do
    liquid_filter = Object.new
    liquid_filter.extend(Liquid::StandardFilters)
    (liquid_filter.date_orig("now", "%Y") rescue "").should_not == Time.now.year.to_s
  end
end

describe "curly quote patch" do
  # if this test fails, the workaround for the "markdown" filter can be removed
  it "is necessary" do
    renderer = Redcarpet::Markdown.new(Serif::MarkupRenderer)
    renderer.render("something's here").should_not include("something&rsquo;s here")
  end
end

require "serif"
require "fileutils"
require "pathname"
require "time"
require "date"
require "timecop"

def testing_dir(path = nil)
  full_path = File.join(File.dirname(__FILE__), "site_dir")

  path ? File.join(full_path, path) : full_path
end

def capture_stdout
  begin
    $orig_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.rewind
    return $stdout.string
  ensure
    $stdout = $orig_stdout
  end
end
