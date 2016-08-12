class User < ApplicationRecord
  has_many :repos, dependent: :delete_all
  has_many :rebases, through: :repos

  def update_with_github(info, token)
    self.name = info.name
    self.username = info.login
    self.email = info.email
    self.avatar = info.avatar_url
    self.token = token
    save
  end

  def github
    @github ||= Octokit::Client.new(access_token: token, per_page: 100)
  end
end
