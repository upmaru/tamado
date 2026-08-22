# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

home = Project.find_or_create_by!(name: "Home")
work = Project.find_or_create_by!(name: "Work")

groceries = home.lists.find_or_create_by!(name: "Groceries")
chores = home.lists.find_or_create_by!(name: "Chores")
sprint = work.lists.find_or_create_by!(name: "Sprint")

[
  [ groceries, "Buy milk", true ],
  [ groceries, "Buy eggs", false ],
  [ groceries, "Pick up bread", true ],
  [ chores, "Fix the leaky tap", false ],
  [ chores, "Water the plants", true ],
  [ sprint, "Write onboarding docs", false ],
  [ sprint, "Review pull requests", true ],
  [ sprint, "Plan the release", false ]
].each do |list, description, completed|
  item = list.items.find_or_create_by!(description: description)
  item.complete! if completed && item.pending?
end
