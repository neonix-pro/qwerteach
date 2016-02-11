# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Init des niveaux
Level.create(:level_code=>1, :value=>"Primary school")
Level.create(:level_code=>2, :value=>"Secondary school - lower")
Level.create(:level_code=>3, :value=>"Secondary school - upper")
Level.create(:level_code=>4, :value=>"Bachelor")
Level.create(:level_code=>5, :value=>"Master")
Level.create(:level_code=>6, :value=>"Doctorat")

