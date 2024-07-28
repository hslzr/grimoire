class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  before_create :set_uuid

  private

  def set_uuid
    return if self.class.attribute_types["id"].type != :uuid

    self.id ||= SecureRandom.uuid_v7
  end
end
