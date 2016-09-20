FactoryGirl.define do
  factory :level do
    level { rand(1..20) }
    code { ["scolaire", "divers", "langue"].sample }
    fr { ["Primaire", "Secondaire I", "Secondaire II", "Baccalauréat universitaire", "Maîtrise universitaire", "Doctorat", "Débutant", "Intermédiaire", "Expert", "A0 Débutant", "A1 Élémentaire", "A2 Pré-intermédiaire", "B1 Intermédiaire", "B2 Intermédiaire supérieur", "C1 Avancé", "C2 Compétent/Courant"].sample }
    be { ["Primaire", "Secondaire inférieur", "Secondaire supérieur", "Baccalauréat universitaire", "Maîtrise universitaire", "Doctorat", "Débutant", "Intermédiaire", "Expert", "A0 Débutant", "A1 Élémentaire", "A2 Pré-intermédiaire", "B1 Intermédiaire", "B2 Intermédiaire supérieur", "C1 Avancé", "C2 Compétent/Courant"].sample }
    ch { ["Primaire", "Secondaire I", "Secondaire II", "Baccalauréat universitaire", "Maîtrise universitaire", "Doctorat", "Débutant", "Intermédiaire", "Expert", "A0 Débutant", "A1 Élémentaire", "A2 Pré-intermédiaire", "B1 Intermédiaire", "B2 Intermédiaire supérieur", "C1 Avancé", "C2 Compétent/Courant"].sample }

    factory :level_5 do
      level 5
      code 'langue'
      fr 'B2 Intermédiaire supérieure'
      ch 'B2 Intermédiaire supérieur'
      be 'B2 Intermédiaire supérieur'
    end

    factory :level_10 do
      level 10
      code 'scolaire'
      fr 'Lycée'
      ch 'Secondaire II'
      be 'Secondaire supérieur'
    end

    factory :level_15 do
      level 15
      code 'scolaire'
      fr 'Baccalauréat universitaire'
      ch 'Baccalauréat universitaire'
      be 'Baccalauréat universitaire'
    end

  end
end