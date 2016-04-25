# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Init des niveaux
Level.create(:code=>Level::LEVEL_CODE[0], :level=>1, :be=>"Primaire", :fr=>"Primaire", :ch=>"Primaire")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>2, :be=>"Primaire", :fr=>"Primaire", :ch=>"Primaire")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>3, :be=>"Primaire", :fr=>"Primaire", :ch=>"Primaire")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>4, :be=>"Primaire", :fr=>"Primaire", :ch=>"Primaire")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>5, :be=>"Primaire", :fr=>"Primaire", :ch=>"Primaire")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>6, :be=>"Primaire", :fr=>"Collège", :ch=>"Primaire")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>7, :be=>"Secondaire inférieur", :fr=>"Collège", :ch=>"Secondaire I")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>8, :be=>"Secondaire inférieur", :fr=>"Collège", :ch=>"Secondaire I")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>9, :be=>"Secondaire inférieur", :fr=>"Collège", :ch=>"Secondaire I")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>10, :be=>"Secondaire supérieur", :fr=>"Lycée", :ch=>"Secondaire II")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>11, :be=>"Secondaire supérieur", :fr=>"Lycée", :ch=>"Secondaire II")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>12, :be=>"Secondaire supérieur", :fr=>"Lycée", :ch=>"Secondaire II")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>13, :be=>"Baccalauréat universitaire", :fr=>"Baccalauréat universitaire", :ch=>"Baccalauréat universitaire")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>14, :be=>"Baccalauréat universitaire", :fr=>"Baccalauréat universitaire", :ch=>"Baccalauréat universitaire")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>15, :be=>"Baccalauréat universitaire", :fr=>"Baccalauréat universitaire", :ch=>"Baccalauréat universitaire")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>16, :be=>"Maîtrise universitaire", :fr=>"Maîtrise universitaire", :ch=>"Maîtrise universitaire")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>17, :be=>"Maîtrise universitaire", :fr=>"Maîtrise universitaire", :ch=>"Maîtrise universitaire")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>18, :be=>"Maîtrise universitaire", :fr=>"Maîtrise universitaire", :ch=>"Maîtrise universitaire")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>19, :be=>"Doctorat", :fr=>"Doctorat", :ch=>"Doctorat")
Level.create(:code=>Level::LEVEL_CODE[0], :level=>20, :be=>"Doctorat", :fr=>"Doctorat", :ch=>"Doctorat")


Level.create(:code=>Level::LEVEL_CODE[1], :level=>1, :be=>"Débutant", :fr=>"Débutant", :ch=>"Débutant")
Level.create(:code=>Level::LEVEL_CODE[1], :level=>2, :be=>"Intermédiaire", :fr=>"Intermédiaire", :ch=>"Intermédiaire")
Level.create(:code=>Level::LEVEL_CODE[1], :level=>3, :be=>"Expert", :fr=>"Expert", :ch=>"Expert")

Level.create(:code=>Level::LEVEL_CODE[2], :level=>1, :be=>"A0 Débutant", :fr=>"A0 Débutant", :ch=>"A0 Débutant")
Level.create(:code=>Level::LEVEL_CODE[2], :level=>2, :be=>"A1 Élémentaire", :fr=>"A1 Élémentaire", :ch=>"A1 Élémentaire")
Level.create(:code=>Level::LEVEL_CODE[2], :level=>3, :be=>"A2 Pré-intermédiaire", :fr=>"A2 Pré-intermédiaire", :ch=>"A2 Pré-intermédiaire")
Level.create(:code=>Level::LEVEL_CODE[2], :level=>4, :be=>"B1 Intermédiaire", :fr=>"B1 Intermédiaire", :ch=>"B1 Intermédiaire")
Level.create(:code=>Level::LEVEL_CODE[2], :level=>5, :be=>"B2 Intermédiaire supérieur", :fr=>"B2 Intermédiaire supérieur", :ch=>"B2 Intermédiaire supérieur")
Level.create(:code=>Level::LEVEL_CODE[2], :level=>6, :be=>"C1 Avancé", :fr=>"C1 Avancé", :ch=>"C1 Avancé")
Level.create(:code=>Level::LEVEL_CODE[2], :level=>7, :be=>"C2 Compétent/Courant", :fr=>"C2 Compétent/Courant", :ch=>"C2 Compétent/Courant")

TopicGroup.create(:title => "Mathématiques", :level_code => "scolaire")
TopicGroup.create(:title => "Sciences", :level_code => "scolaire")
TopicGroup.create(:title => "Lettres", :level_code => "scolaire")
TopicGroup.create(:title => "Langues", :level_code => "langue")
TopicGroup.create(:title => "Economie", :level_code => "scolaire")
TopicGroup.create(:title => "Informatique", :level_code => "scolaire")

Topic.create(:topic_group_id => 1 ,:title => "Mathématiques")
Topic.create(:topic_group_id => 1 ,:title => "Statistiques")
Topic.create(:topic_group_id => 1 ,:title => "Other")

Topic.create(:topic_group_id => 2 ,:title => "Physique")
Topic.create(:topic_group_id => 2 ,:title => "Chimie")
Topic.create(:topic_group_id => 2 ,:title => "Biologie")
Topic.create(:topic_group_id => 2 ,:title => "Other")

Topic.create(:topic_group_id => 3 ,:title => "Français")
Topic.create(:topic_group_id => 3 ,:title => "Latin")
Topic.create(:topic_group_id => 3 ,:title => "Grec")
Topic.create(:topic_group_id => 3 ,:title => "Philosophie")
Topic.create(:topic_group_id => 3 ,:title => "Other")

Topic.create(:topic_group_id => 4 ,:title => "Français")
Topic.create(:topic_group_id => 4 ,:title => "Néerlandais")
Topic.create(:topic_group_id => 4 ,:title => "Anglais")
Topic.create(:topic_group_id => 4 ,:title => "Espagnol")
Topic.create(:topic_group_id => 4 ,:title => "Allemand")
Topic.create(:topic_group_id => 4 ,:title => "Other")

Topic.create(:topic_group_id => 5 ,:title => "Microéconomie")
Topic.create(:topic_group_id => 5 ,:title => "Macroéconomie")
Topic.create(:topic_group_id => 5 ,:title => "Finance")
Topic.create(:topic_group_id => 5 ,:title => "Other")

Topic.create(:topic_group_id => 6 ,:title => "Bureautique")
Topic.create(:topic_group_id => 6 ,:title => "Programmation")
Topic.create(:topic_group_id => 6 ,:title => "Réseaux")
Topic.create(:topic_group_id => 6 ,:title => "Base de données")
Topic.create(:topic_group_id => 6 ,:title => "Other")



User.create({:name => 'username', :email => 'user@name.fr', :password=>'arrow', :password_confirmation =>'arrow'})
u.avartar = File.open('/public/system/defaults/small/missing.png')
u.save!