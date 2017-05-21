TopicGroup.create!([
  {title: "Mathématiques", level_code: "scolaire", featured: true, picto: "matieres/maths.png"},
  {title: "Sciences", level_code: "scolaire", featured: true, picto: "matieres/sciences.png"},
  {title: "Lettres", level_code: "scolaire", featured: false, picto: nil},
  {title: "Langues", level_code: "langue", featured: false, picto: nil},
  {title: "Economie", level_code: "scolaire", featured: false, picto: nil},
  {title: "Informatique", level_code: "scolaire", featured: true, picto: "matieres/informatique.png"},
  {title: "Autre", level_code: "scolaire", featured: false, picto: nil}
])

Level.create!([
  {level: 1, code: "scolaire", be: "Primaire", fr: "Primaire", ch: "Primaire"},
  {level: 2, code: "scolaire", be: "Primaire", fr: "Primaire", ch: "Primaire"},
  {level: 3, code: "scolaire", be: "Primaire", fr: "Primaire", ch: "Primaire"},
  {level: 4, code: "scolaire", be: "Primaire", fr: "Primaire", ch: "Primaire"},
  {level: 5, code: "scolaire", be: "Primaire", fr: "Primaire", ch: "Primaire"},
  {level: 6, code: "scolaire", be: "Primaire", fr: "Collège", ch: "Primaire"},
  {level: 7, code: "scolaire", be: "Secondaire inférieur", fr: "Collège", ch: "Secondaire I"},
  {level: 8, code: "scolaire", be: "Secondaire inférieur", fr: "Collège", ch: "Secondaire I"},
  {level: 9, code: "scolaire", be: "Secondaire inférieur", fr: "Collège", ch: "Secondaire I"},
  {level: 10, code: "scolaire", be: "Secondaire supérieur", fr: "Lycée", ch: "Secondaire II"},
  {level: 11, code: "scolaire", be: "Secondaire supérieur", fr: "Lycée", ch: "Secondaire II"},
  {level: 12, code: "scolaire", be: "Secondaire supérieur", fr: "Lycée", ch: "Secondaire II"},
  {level: 13, code: "scolaire", be: "Baccalauréat universitaire", fr: "Baccalauréat universitaire", ch: "Baccalauréat universitaire"},
  {level: 14, code: "scolaire", be: "Baccalauréat universitaire", fr: "Baccalauréat universitaire", ch: "Baccalauréat universitaire"},
  {level: 15, code: "scolaire", be: "Baccalauréat universitaire", fr: "Baccalauréat universitaire", ch: "Baccalauréat universitaire"},
  {level: 16, code: "scolaire", be: "Maîtrise universitaire", fr: "Maîtrise universitaire", ch: "Maîtrise universitaire"},
  {level: 17, code: "scolaire", be: "Maîtrise universitaire", fr: "Maîtrise universitaire", ch: "Maîtrise universitaire"},
  {level: 18, code: "scolaire", be: "Maîtrise universitaire", fr: "Maîtrise universitaire", ch: "Maîtrise universitaire"},
  {level: 19, code: "scolaire", be: "Doctorat", fr: "Doctorat", ch: "Doctorat"},
  {level: 20, code: "scolaire", be: "Doctorat", fr: "Doctorat", ch: "Doctorat"},
  {level: 1, code: "divers", be: "Débutant", fr: "Débutant", ch: "Débutant"},
  {level: 2, code: "divers", be: "Intermédiaire", fr: "Intermédiaire", ch: "Intermédiaire"},
  {level: 3, code: "divers", be: "Expert", fr: "Expert", ch: "Expert"},
  {level: 1, code: "langue", be: "A0 Débutant", fr: "A0 Débutant", ch: "A0 Débutant"},
  {level: 2, code: "langue", be: "A1 Élémentaire", fr: "A1 Élémentaire", ch: "A1 Élémentaire"},
  {level: 3, code: "langue", be: "A2 Pré-intermédiaire", fr: "A2 Pré-intermédiaire", ch: "A2 Pré-intermédiaire"},
  {level: 4, code: "langue", be: "B1 Intermédiaire", fr: "B1 Intermédiaire", ch: "B1 Intermédiaire"},
  {level: 5, code: "langue", be: "B2 Intermédiaire supérieur", fr: "B2 Intermédiaire supérieur", ch: "B2 Intermédiaire supérieur"},
  {level: 6, code: "langue", be: "C1 Avancé", fr: "C1 Avancé", ch: "C1 Avancé"},
  {level: 7, code: "langue", be: "C2 Compétent/Courant", fr: "C2 Compétent/Courant", ch: "C2 Compétent/Courant"}
])
Topic.create!([
  {title: "maths", topic_group_id:1}, # 1
  {title: "statistiques", topic_group_id:1}, # 2
  {title: "physique", topic_group_id:2}, # 3
  {title: "chimie", topic_group_id:2},# 4
  {title: "biologie", topic_group_id:2},# 5
  {title: "biochimie", topic_group_id:2}, # 6
  {title: "francais", topic_group_id:3},# 7
  {title: "latin", topic_group_id:3},# 8
  {title: "grec", topic_group_id:3},# 9
  {title: "philosophie", topic_group_id:3},# 10
  {title: "littérature", topic_group_id:3},# 11
  {title: "histoire", topic_group_id:3},# 12
  {title: "fle", topic_group_id:4},# 13
  {title: "neerlandais", topic_group_id:4},# 14
  {title: "anglais", topic_group_id:4},# 15
  {title: "espagnol", topic_group_id:4},# 16
  {title: "allemand", topic_group_id:4},# 17
  {title: "italien", topic_group_id:4},# 18
  {title: "microeconomie", topic_group_id:5},# 19
  {title: "macroeconomie", topic_group_id:5},# 20
  {title: "finance", topic_group_id:5},# 21
  {title: "economie", topic_group_id:5},# 22
  {title: "bureautique", topic_group_id:6},# 23
  {title: "programmation", topic_group_id:6},# 24
  {title: "reseaux", topic_group_id:6},# 25
  {title: "base de donnees", topic_group_id:6}, # 26
  {title: "Other", topic_group_id:nil}
])