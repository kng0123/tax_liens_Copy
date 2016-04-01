class Note < ActiveRecord::Base
  belongs_to :lien
  belongs_to :profile

  def serializable_hash(options)
    # return {}
    data = super.to_hash
    data["name"] = self.name
    data
  end

  def name
    if !self.profile.nil?
      self.profile.name
    end
  end
end
