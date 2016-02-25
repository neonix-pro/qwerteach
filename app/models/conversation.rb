class Conversation < ActiveRecord::Base
  belongs_to :sender, :foreign_key => :sender_id, class_name: 'User'
  belongs_to :recipient, :foreign_key => :recipient_id, class_name: 'User'

  has_many :messages, dependent: :destroy

  #empêche de créer deux conversations entre les deux mêmes users 
  #(user 1 et user 2 est la même conversation que user2 et user1)
  validates_uniqueness_of :sender_id, :scope => :recipient_id

  #scope définit une méthode pour récupérer les conversations impliquant un utilisateur
  #avec Conversation.involving(user_id)
  scope :involving, -> (user) do
    where("conversations.sender_id =? OR conversations.recipient_id =?",user.id,user.id)
  end
  #idem mais pour récupérer la conversation entre deux users
  #Conversation.between(sender_id, recipient_id)
  scope :between, -> (sender_id,recipient_id) do
    where("(conversations.sender_id = ? AND conversations.recipient_id =?) OR (conversations.sender_id = ? AND conversations.recipient_id =?)", sender_id,recipient_id, recipient_id, sender_id)
  end
end
