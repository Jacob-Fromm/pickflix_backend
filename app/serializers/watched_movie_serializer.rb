class WatchedMovieSerializer < ActiveModel::Serializer
  attributes :id
  has_one :user
  has_one :movie
end