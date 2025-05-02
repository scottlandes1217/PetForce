namespace :admin do
  desc "Create an admin user"
  task create_admin: :environment do
    User.create!(
      email: 'scottandvega@gmail.com',
      password: 'password123',
      role: 'admin'
    )
    puts "Admin user created successfully!"
  end
end 