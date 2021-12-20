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
    lorem: Faker::Lorem.paragraph_by_chars(number: 1000, supplemental: true)
}

@data2 = {
    lorem: Faker::Lorem.paragraph_by_chars(number: 10000, supplemental: true),
    profession: Faker::Job.title,
    email: Faker::Internet.unique.email,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.unique.cell_phone 
}

def create_dataset(nb_documents = 10, base_id)
    documents = []
    nb_documents.times do |n|
        documents << { base_id: base_id + n,
        username: Faker::Esport.player,
        name: Faker::Name.unique.name,
        }.merge(@data2)
    end
    return documents
end

client = MeiliSearch::Client.new('https://ms-40e9b27258bc-133.saas.meili.dev', '994073c2a74b45c47403acfefd2ef97d8f6b1467')

index_name = 'lorem'
index = client.index(index_name)

nb_documents = 500000
batch_size = 10000

nb_send = (nb_documents/batch_size).ceil
base_id = 0

client.index(index_name).update_filterable_attributes([
  'username',
  'name'
])

nb_send.times do |nb|
    documents = create_dataset(batch_size, base_id)
    index.add_documents(documents)
    base_id = base_id + batch_size
    puts "batch #{nb + 1} done"
end



