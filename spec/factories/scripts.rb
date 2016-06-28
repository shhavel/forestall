FactoryGirl.define do
  factory :script do
    site
    name 'Page content'
    type 'html'
    content '<html>content</html>'
  end
end
