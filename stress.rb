#!/usr/bin/ruby

require 'bundler/inline'

puts "Installing gems if needed..."

gemfile do
    source 'https://rubygems.org'
    gem 'faker'
    gem 'meilisearch'
end

puts "Installation done"

require 'faker'
require 'meilisearch'
require 'set'

@data = {
    username: Faker::Esport.player,
    name: Faker::Name.unique.name,
    profession: Faker::Job.title,
    email: Faker::Internet.unique.email,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.unique.cell_phone,
    lorem: Faker::Lorem.paragraph_by_chars(number: 10000, supplemental: true)
}

def create_dataset(nb_documents = 10, base_id)
    documents = []
    nb_documents.times do |n|
        documents << { base_id: base_id + n }.merge(@data)
    end
    return documents
end

client = MeiliSearch::Client.new('https://ms-710d8ca6bff8-133.saas.meili.dev', '14b5ddf195bd156fbac296569bbcbf71a79228a1')

index = client.index('gaming')

nb_documents = 500000
batch_size = 1000

nb_send = (nb_documents/batch_size).ceil
base_id = 0

nb_send.times do |nb|
    documents = create_dataset(batch_size, base_id)
    index.add_documents(documents)
    base_id = base_id + batch_size
    puts "batch #{nb + 1} done"
end



