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
TopicGroup.create(:title => "Autre", :level_code => "scolaire")

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

Topic.create(:topic_group_id => 7 ,:title => "Other")

Bigbluebutton::BigbluebuttonServer.create(name: "BBB_prod", url: "http://classevirtuelle.qwerteach.com/bigbluebutton/api", salt: "f3b1e2b44deea958cb3503c032310d3c", version: "0.9", param: "bbb_prod")

# student
u = User.create(:email => "a@a.a",:firstname => "Macaque", :lastname => "Selfieur",  :password => "kaltrina", :encrypted_password => "$2a$10$kdhcUGrsb7gBk.RHrs2xK.OHMx5gdx7kmLHFozZgRdtigrlbt91Zu", :confirmation_token => "2016-04-25 08:38:01.794476", :confirmation_sent_at => "2016-04-25 08:38:01.794477", :confirmed_at => "2016-04-25 08:38:01.794477",
            :avatar_file_name=> "hello.jpg", :avatar_content_type => "image/jpeg", :avatar_file_size => 64813, :avatar_updated_at => "2016-04-25 09:42:55", :time_zone => "Europe/Berlin")
u.avatar = File.open("#{Rails.root}/public/system/avatars/seeds/original/hello.jpg")
u.save!


# student admin
u2 = User.create(:email => "b@b.b",:firstname => "Chimpanzé", :lastname => "Souriant", :password => "kaltrina", :encrypted_password => "$2a$10$kdhcUGrsb7gBk.RHrs2xK.OHMx5gdx7kmLHFozZgRdtigrlbt91Zu", :confirmation_token => "2016-04-25 08:38:01.794477", :confirmation_sent_at => "2016-04-25 08:38:01.794477", :confirmed_at => "2016-04-25 08:38:01.794477",
                :avatar_file_name=> "hello2.jpg", :avatar_content_type => "image/jpeg", :avatar_file_size => 64813, :avatar_updated_at => "2016-04-25 09:42:55", :admin => true, :time_zone => "Europe/Berlin")
u2.avatar = File.open("#{Rails.root}/public/system/avatars/seeds/original/hello2.jpg")
u2.save!

# teacher
u3 = User.create(:email => "c@c.c",:firstname => "Bonobo", :lastname => "Chauve", :password => "kaltrina", :encrypted_password => "$2a$10$kdhcUGrsb7gBk.RHrs2xK.OHMx5gdx7kmLHFozZgRdtigrlbt91Zu", :confirmation_token => "2016-04-25 08:38:01.794478", :confirmation_sent_at => "2016-04-25 08:38:01.794477", :confirmed_at => "2016-04-25 08:38:01.794477",
                 :avatar_file_name=> "hello3.jpg", :avatar_content_type => "image/jpeg", :avatar_file_size => 64813, :avatar_updated_at => "2016-04-25 09:42:55", :type => 'Teacher', :time_zone => "Europe/Berlin")
u3.avatar = File.open("#{Rails.root}/public/system/avatars/seeds/original/hello3.jpg")
u3.save!

u5 = User.create(:email => "e@e.e",:firstname => "Bébé", :lastname => "Chimpanzé", :password => "kaltrina", :encrypted_password => "$2a$10$kdhcUGrsb7gBk.RHrs2xK.OHMx5gdx7kmLHFozZgRdtigrlbt91Zu", :confirmation_token => "2016-04-25 08:38:01.794479", :confirmation_sent_at => "2016-04-25 08:38:01.794477", :confirmed_at => "2016-04-25 08:38:01.794477",
                 :avatar_file_name=> "hello3.jpg", :avatar_content_type => "image/jpeg", :avatar_file_size => 64813, :avatar_updated_at => "2016-04-25 09:42:55", :type => 'Teacher', :time_zone => "Europe/Berlin")
u5.avatar = File.open("#{Rails.root}/public/system/avatars/seeds/original/hello5.jpg")
u5.save!

u6 = User.create(:email => "f@f.f",:firstname => "Garau", :lastname => "Gorille", :password => "kaltrina", :encrypted_password => "$2a$10$kdhcUGrsb7gBk.RHrs2xK.OHMx5gdx7kmLHFozZgRdtigrlbt91Zu", :confirmation_token => "2016-04-25 08:38:01.794480", :confirmation_sent_at => "2016-04-25 08:38:01.794477", :confirmed_at => "2016-04-25 08:38:01.794477",
                 :avatar_file_name=> "hello3.jpg", :avatar_content_type => "image/jpeg", :avatar_file_size => 64813, :avatar_updated_at => "2016-04-25 09:42:55", :type => 'Teacher', :time_zone => "Europe/Berlin")
u6.avatar = File.open("#{Rails.root}/public/system/avatars/seeds/original/hello6.jpg")
u6.save!

u7 = User.create(:email => "g@g.g",:firstname => "Tetede", :lastname => "Bite", :password => "kaltrina", :encrypted_password => "$2a$10$kdhcUGrsb7gBk.RHrs2xK.OHMx5gdx7kmLHFozZgRdtigrlbt91Zu", :confirmation_token => "2016-04-25 08:38:01.794481", :confirmation_sent_at => "2016-04-25 08:38:01.794477", :confirmed_at => "2016-04-25 08:38:01.794477",
                 :avatar_file_name=> "hello3.jpg", :avatar_content_type => "image/jpeg", :avatar_file_size => 64813, :avatar_updated_at => "2016-04-25 09:42:55", :type => 'Teacher', :time_zone => "Europe/Berlin")
u7.avatar = File.open("#{Rails.root}/public/system/avatars/seeds/original/hello7.jpg")
u7.save!

u8 = User.create(:email => "h@h.h",:firstname => "Impoli", :lastname => "Poilu", :password => "kaltrina", :encrypted_password => "$2a$10$kdhcUGrsb7gBk.RHrs2xK.OHMx5gdx7kmLHFozZgRdtigrlbt91Zu", :confirmation_token => "2016-04-25 08:38:01.794482", :confirmation_sent_at => "2016-04-25 08:38:01.794477", :confirmed_at => "2016-04-25 08:38:01.794477",
                 :avatar_file_name=> "hello3.jpg", :avatar_content_type => "image/jpeg", :avatar_file_size => 64813, :avatar_updated_at => "2016-04-25 09:42:55", :type => 'Teacher', :time_zone => "Europe/Berlin")
u8.avatar = File.open("#{Rails.root}/public/system/avatars/seeds/original/hello8.jpg")
u8.save!

# teacher admin

u4 = User.create(:email => "d@d.d",:firstname => "Grosse", :lastname => "Tete", :password => "kaltrina", :encrypted_password => "$2a$10$kdhcUGrsb7gBk.RHrs2xK.OHMx5gdx7kmLHFozZgRdtigrlbt91Zu", :confirmation_token => "51d7292b4823498d5d8795ec30bd7e92d014d89fd0fe685ae006fa2adc08479d", :confirmation_sent_at => "2016-04-25 08:38:01.794477", :confirmed_at => "2016-04-25 08:38:01.794477",
                 :avatar_file_name=> "hello4.jpg", :avatar_content_type => "image/jpeg", :avatar_file_size => 64813, :avatar_updated_at => "2016-04-25 09:42:55", :type => 'Teacher', :admin => true, :postulance_accepted => true, :time_zone => "Europe/Berlin")
u4.avatar = File.open("#{Rails.root}/public/system/avatars/seeds/original/hello4.jpg")
u4.save!

# Third user's adverts
a1 = Advert.create(:user => u3, :topic_id => 5, :topic_group_id => 2)
ap1 = AdvertPrice.create(:advert => a1, :level_id => 5, :price => 15.0)
ap2 = AdvertPrice.create(:advert => a1, :level_id => 9, :price => 20.0)
ap3 = AdvertPrice.create(:advert => a1, :level_id => 12, :price => 25.0)

a2 = Advert.create(:user => u3, :topic_id => 15,  :topic_group_id => 4)
ap1 = AdvertPrice.create(:advert => a2, :level_id => 27, :price => 16.0)
ap2 = AdvertPrice.create(:advert => a2, :level_id => 28, :price => 21.0)
ap3 = AdvertPrice.create(:advert => a2, :level_id => 29, :price => 24.0)

# Fourth user's adverts
a3 = Advert.create(:user => u4, :topic_id => 24, :topic_group_id => 6)
ap1 = AdvertPrice.create(:advert => a3, :level_id => 9, :price => 14.0)
ap2 = AdvertPrice.create(:advert => a3, :level_id => 12, :price => 16.0)
ap3 = AdvertPrice.create(:advert => a3, :level_id => 15, :price => 18.0)

a4 = Advert.create(:user => u4, :topic_id => 21, :topic_group_id => 5)
ap2 = AdvertPrice.create(:advert => a4, :level_id => 18, :price => 24.0)
ap3 = AdvertPrice.create(:advert => a4, :level_id => 20, :price => 28.0)

# Fifth user's adverts
a = Advert.create(:user => u5, :topic_id => 1, :topic_group_id => 1)
ap = AdvertPrice.create(:advert => a, :level_id => 9, :price => 15.0)
ap = AdvertPrice.create(:advert => a, :level_id => 12, :price => 20.0)
ap = AdvertPrice.create(:advert => a, :level_id => 15, :price => 25.0)

a = Advert.create(:user => u5, :topic_id => 2, :topic_group_id => 1)
ap = AdvertPrice.create(:advert => a, :level_id => 9, :price => 15.0)
ap = AdvertPrice.create(:advert => a, :level_id => 12, :price => 20.0)
ap = AdvertPrice.create(:advert => a, :level_id => 15, :price => 25.0)

a = Advert.create(:user => u5, :topic_id => 5, :topic_group_id => 2)
ap = AdvertPrice.create(:advert => a, :level_id => 9, :price => 15.0)
ap = AdvertPrice.create(:advert => a, :level_id => 12, :price => 20.0)
ap = AdvertPrice.create(:advert => a, :level_id => 15, :price => 25.0)

a = Advert.create(:user => u5, :topic_id => 4, :topic_group_id => 2)
ap = AdvertPrice.create(:advert => a, :level_id => 9, :price => 15.0)
ap = AdvertPrice.create(:advert => a, :level_id => 12, :price => 20.0)
ap = AdvertPrice.create(:advert => a, :level_id => 15, :price => 25.0)

# Sixth user's adverts
a = Advert.create(:user => u6, :topic_id => 4, :topic_group_id => 2)
ap = AdvertPrice.create(:advert => a, :level_id => 12, :price => 20.0)
ap = AdvertPrice.create(:advert => a, :level_id => 15, :price => 20.0)

a = Advert.create(:user => u6, :topic_id => 5, :topic_group_id => 2)
ap = AdvertPrice.create(:advert => a, :level_id => 12, :price => 20.0)
ap = AdvertPrice.create(:advert => a, :level_id => 15, :price => 20.0)

a = Advert.create(:user => u6, :topic_id => 6, :topic_group_id => 2)
ap = AdvertPrice.create(:advert => a, :level_id => 12, :price => 20.0)
ap = AdvertPrice.create(:advert => a, :level_id => 15, :price => 20.0)

# Seventh user's adverts
a = Advert.create(:user => u7, :topic_id => 15, :topic_group_id => 4)
ap = AdvertPrice.create(:advert => a, :level_id => 27, :price => 40.0)
ap = AdvertPrice.create(:advert => a, :level_id => 28, :price => 50.0)
ap = AdvertPrice.create(:advert => a, :level_id => 29, :price => 50.0)
ap = AdvertPrice.create(:advert => a, :level_id => 30, :price => 50.0)

a = Advert.create(:user => u7, :topic_id => 16, :topic_group_id => 4)
ap = AdvertPrice.create(:advert => a, :level_id => 27, :price => 40.0)
ap = AdvertPrice.create(:advert => a, :level_id => 28, :price => 50.0)
ap = AdvertPrice.create(:advert => a, :level_id => 29, :price => 50.0)
ap = AdvertPrice.create(:advert => a, :level_id => 30, :price => 50.0)

a = Advert.create(:user => u7, :topic_id => 17, :topic_group_id => 4)
ap = AdvertPrice.create(:advert => a, :level_id => 27, :price => 40.0)
ap = AdvertPrice.create(:advert => a, :level_id => 28, :price => 50.0)
ap = AdvertPrice.create(:advert => a, :level_id => 29, :price => 50.0)
ap = AdvertPrice.create(:advert => a, :level_id => 30, :price => 50.0)


