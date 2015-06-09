FactoryGirl.define do
    factory :user do
        username    "testuser"
        name        "Mr. Test"
        email       "testuser@example.com"
        password    "Password"
    end

    factory :group do
        name        "testgroup"
    end

    factory :snippet do
        user
        title       "testsnippet"
        private     true

        transient do
            snippet_files_count 3
        end

        after(:create) do |snippet, evaluator|
            evaluator.snippet_files_count.times do |n|
                create(:snippet_file, snippet: snippet, filename: "testfile#{n}.txt")
            end
        end
    end

    factory :snippet_file do
        snippet     
        filename    "testfile.txt"
        language    "text"
        content     { "#{filename} content" }
        score       0
        tags        ["text", "test"]
    end
end

