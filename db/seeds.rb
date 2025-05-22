# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


Rubit.destroy_all
Like.destroy_all
User.destroy_all
Product.destroy_all
Cart.destroy_all


user = []

20.times do |i|
  new_user = User.create!(
    email:                 "user#{i + 1}@example.com",
    password:              'password',
    password_confirmation: 'password',
    username:              "user#{i + 1}",
  )
  new_user.create_cart!
  user << new_user
end

user[1].rubits.create!(content: 'Finally figured out how to debug in #rails! Now I feel like a wizard 🧙‍♂️')
user[1].rubits.create!(content: 'Can we just talk about how #JavaScript’s async/await made my life easier? #Blessed')
user[1].rubits.create!(content: 'Just got into #machinelearning and I feel like I’m in over my head. Anyone else? 🤖')
user[1].rubits.create!(content: 'I’ve been trying to use #Docker for 2 days now and I swear, it’s like taming a lion. 🦁')
user[1].rubits.create!(content: 'It’s crazy how many #gems I’m discovering for #rails! The community really is amazing!')

user[2].rubits.create!(content: 'Can’t decide whether I should stick to #React or dive into #Vue. Both are so tempting. 🤔')
user[2].rubits.create!(content: 'Finally got #GraphQL working after hours of struggle. Never been more proud of myself. 🙌')
user[2].rubits.create!(content: 'The #Redux pattern is giving me a headache, but I’m determined to get it right. #FrontEndDev')
user[2].rubits.create!(content: 'Trying to optimize my #NodeJS backend, but these bugs are driving me crazy! 🐞')
user[2].rubits.create!(content: 'Is anyone else obsessed with #webpack? Or am I the only one? 😬')

user[3].rubits.create!(content: 'Just finished building my first app with #Django! That framework is smooth! 🚀')
user[3].rubits.create!(content: 'Learning #Python is a game changer, it’s like the Swiss army knife of programming languages. 🛠️')
user[3].rubits.create!(content: 'Getting into #AI has my brain in knots. But I think I’m finally starting to understand it. 🤯')
user[3].rubits.create!(content: 'Spent the last 2 hours debugging code… then I realized I forgot a semicolon. Classic. 😩')
user[3].rubits.create!(content: 'Just installed #TensorFlow. I feel like I’m about to change the world or break something important. 🤖')

user[4].rubits.create!(content: 'Why do I always seem to break things when I use #Webpack? It’s supposed to make my life easier, right?')
user[4].rubits.create!(content: 'Spent an hour trying to figure out #Sass variables. Finally got it, but why is CSS this confusing? 😅')
user[4].rubits.create!(content: 'Can we talk about how frustrating it is to work with #RESTAPIs? Like, why are they so inconsistent?')
user[4].rubits.create!(content: 'Just spent a full day learning about #CI/CD pipelines. It’s all coming together. Next stop: DevOps! 🚀')
user[4].rubits.create!(content: 'Found a bug in my code after 3 hours of staring at the screen. The bug? A missing comma. 🤦‍♂️')

user[5].rubits.create!(content: 'Spent way too much time making my app look pretty with #CSS. Who knew design could be so hard?')
user[5].rubits.create!(content: 'Learning about #Kubernetes and it feels like I’m trying to solve a Rubik’s Cube while blindfolded. 🧩')
user[5].rubits.create!(content: 'Trying out #TypeScript and so far, it feels like learning a new dialect of JavaScript. 😬')
user[5].rubits.create!(content: 'Why do I always feel like I’m behind on new technology? #ImposterSyndrome')
user[5].rubits.create!(content: 'Just got a #React app to finally deploy. It’s a miracle, but I’ll take it. 🎉')

user[6].rubits.create!(content: 'Just tried out #elixir and I’m amazed. Such a cool language!')
user[6].rubits.create!(content: 'Learning #flutter for cross-platform mobile apps, but it’s so overwhelming!')
user[6].rubits.create!(content: 'Why is #javascript so messy? But, I can’t quit it. 😅')
user[6].rubits.create!(content: 'Started using #docker today... now I know why developers love it!')
user[6].rubits.create!(content: 'Anyone else here obsessed with #tailwindcss? It’s such a time-saver.')

user[7].rubits.create!(content: 'Can’t believe how fast #go is. Started using it today and it’s amazing!')
user[7].rubits.create!(content: 'I need to learn #devops, but where do I even start?')
user[7].rubits.create!(content: 'Building my first #kubernetes deployment. Let’s hope it works!')
user[7].rubits.create!(content: 'Why do #databases have to be so complex? SQL is a beast!')
user[7].rubits.create!(content: 'Struggling with #git merge conflicts... send help!')

user[8].rubits.create!(content: 'Discovered #svelte today, and I’m already in love with it!')
user[8].rubits.create!(content: 'Coding for hours without breaks, my back is telling me it’s time for a stretch.')
user[8].rubits.create!(content: 'Started experimenting with #rust. Is it as good as people say?')
user[8].rubits.create!(content: 'Does anyone else feel like #typescript is just a little too strict?')
user[8].rubits.create!(content: 'Building a simple API with #fastapi and it’s incredibly easy. Where’s the catch?')

user[9].rubits.create!(content: 'I’m trying to learn #flutter, but this #dart syntax is so weird!')
user[9].rubits.create!(content: 'Can’t stop using #nestjs for my nodejs apps. Best framework for #nodejs!')
user[9].rubits.create!(content: 'Trying to optimize a #postgresql query, but I feel like I’m just making it worse.')
user[9].rubits.create!(content: 'Is #aws as hard as people say? Just signed up for it.')
user[9].rubits.create!(content: 'Is #graphql really better than REST? I’ve been reading about it all day.')

user[10].rubits.create!(content: 'Started learning #solidity today... blockchain dev here I come!')
user[10].rubits.create!(content: 'Building a personal project with #nextjs, it’s so smooth!')
user[10].rubits.create!(content: 'Has anyone here tried #nestjs? It’s like #expressjs but with more power!')
user[10].rubits.create!(content: 'Trying out #tailwindcss for the first time... I think I’m falling in love!')
user[10].rubits.create!(content: 'Spent all day setting up #ci_cd pipelines. Wish I knew how to automate the setup.')

user[11].rubits.create!(content: "Started using #pyqt to build a GUI for my Python app. It's a bit tricky!")
user[11].rubits.create!(content: "Can't decide if I should learn #graphql or improve my REST skills first...")
user[11].rubits.create!(content: 'Testing out #mongodb for a new app. I feel like I’m going down the #nosql rabbit hole.')
user[11].rubits.create!(content: "Finally getting the hang of #redux. Anyone else feel like it's overkill for small apps?")
user[11].rubits.create!(content: 'Started using #storybook to document my React components. It’s a game-changer!')

user[12].rubits.create!(content: 'Exploring #deno after years of #nodejs. Honestly, the new runtime is refreshing.')
user[12].rubits.create!(content: 'I think I’m finally starting to understand how #graphql queries work...')
user[12].rubits.create!(content: 'Getting into #flutter but am still struggling with the Dart syntax.')
user[12].rubits.create!(content: 'I feel like every #vuejs tutorial I watch leads me to a rabbit hole.')
user[12].rubits.create!(content: 'Playing around with #tailwindcss but it’s making me rethink my entire approach to design.')

user[13].rubits.create!(content: 'Who else is obsessed with #firebase? It’s got everything you need for web and mobile.')
user[13].rubits.create!(content: 'Looking into #cloudfunctions to scale my app. Hope it works!')
user[13].rubits.create!(content: 'Started using #angular again. I think I forgot everything since I last touched it.')
user[13].rubits.create!(content: 'Anyone else love using #docker to containerize apps? I can’t go back to the old way of doing things.')
user[13].rubits.create!(content: 'Trying out #kotlin for Android development. It’s like Java but with less pain.')

user[14].rubits.create!(content: 'Started writing my first #go script. I’m impressed by how fast it runs.')
user[14].rubits.create!(content: 'Why does #racket always look so weird to me? But I’m trying to learn it anyway.')
user[14].rubits.create!(content: 'Experimenting with #rust. I love the memory safety features but the syntax throws me off.')
user[14].rubits.create!(content: 'Why is #python so slow when you try to scale it? Still love it though.')
user[14].rubits.create!(content: 'Anyone tried out #flutter_web? It’s neat, but I still can’t trust it for production apps.')

user[15].rubits.create!(content: 'Just deployed my first app with #vercel. That was so easy!')
user[15].rubits.create!(content: 'Anyone using #strapi for headless CMS? It’s been a lifesaver for my React projects.')
user[15].rubits.create!(content: 'I’m in love with #nextjs, but #reactjs still confuses me sometimes.')
user[15].rubits.create!(content: 'Learning #swift for iOS development. I can already tell it’s going to be a wild ride.')
user[15].rubits.create!(content: 'Exploring #graphql subscriptions. Can’t believe I never used them before!')

user[16].rubits.create!(content: 'Just started learning #elixir. Why does the syntax feel so clean?')
user[16].rubits.create!(content: 'Trying to figure out how to use #graphql with #rails. Anyone got any good tutorials?')
user[16].rubits.create!(content: 'Finally diving into #rust. The compiler is my new best friend... or worst enemy.')
user[16].rubits.create!(content: 'Why does working with #postgreSQL feel like magic sometimes?')
user[16].rubits.create!(content: 'Diving into #reactnative to build a mobile app. Wish me luck!')

user[17].rubits.create!(content: 'Started using #fastapi for a new Python project. It’s ridiculously fast.')
user[17].rubits.create!(content: 'I’m still amazed by how good #tailwindcss is for rapidly building UIs.')
user[17].rubits.create!(content: 'Learning #typescript this weekend. So far, I’m mostly confused.')
user[17].rubits.create!(content: 'Trying to optimize my #nodejs app. Why does everything seem slow?')
user[17].rubits.create!(content: "Getting into #flutter. It's a bit rough but the potential is huge!")

user[18].rubits.create!(content: 'Exploring #solidity and smart contracts. Blockchain is a whole new world!')
user[18].rubits.create!(content: 'My first #docker container works perfectly... I think? #DockerConfused')
user[18].rubits.create!(content: 'Anyone using #vue3? It’s a massive improvement over the old version.')
user[18].rubits.create!(content: 'Trying to improve my #ci_cd pipeline. Why does it keep failing on me?')
user[18].rubits.create!(content: 'Finally tried #redis for caching today. Now I want to use it for everything.')

user[19].rubits.create!(content: 'Started using #firebase_auth for my project. It’s way easier than I expected.')
user[19].rubits.create!(content: 'Is anyone else completely lost trying to get #react_hooks to work?')
user[19].rubits.create!(content: 'Learning #golang. It’s definitely got a different vibe from #python.')
user[19].rubits.create!(content: 'Looking into #kubectl commands for Kubernetes. It’s like learning a new language.')
user[19].rubits.create!(content: 'Trying #nestjs for the first time. Why does everything feel so modular?')

user[0].rubits.create!(content: 'Finally building something serious with #rails5. The nostalgia is real!')
user[0].rubits.create!(content: 'Spent the day debugging #flask. How do people deal with all the errors?')
user[0].rubits.create!(content: 'Diving into #mongodb for the first time. The NoSQL life is crazy.')
user[0].rubits.create!(content: 'Learning about the #eventloop in #nodejs. Still wrapping my head around it.')
user[0].rubits.create!(content: 'Exploring #vuex for state management in #vuejs. Can’t decide if I love it or hate it.')

rubits = Rubit.all.to_a

rubits.each do |rubit|
  likers = user.sample(rand(0..10))

  likers.each do |liker|
    rubit.likes.create!(user: liker)
  end
end

Product.create!(
  title:       'Rubitter T-shirt',
  description: 'A comfy and stylish t-shirt featuring the iconic Rubitter logo. Perfect for showing off your Rubitter pride wherever you go.',
  price:       29.99,
)

Product.create!(
  title:       'Rubitter Mug',
  description: 'Start your day right with a Rubitter-themed mug. Ideal for sipping coffee or tea while coding.',
  price:       12.50,
)

Product.create!(
  title:       'Rubitter Hoodie',
  description: 'Stay warm and cozy with the Rubitter hoodie. A must-have for Rubitter enthusiasts during those late-night coding sessions.',
  price:       39.99,
)

Product.create!(
  title:       'Rubitter Hat',
  description: 'This stylish Rubitter beanie will keep your head warm while showing your love for Rubitter programming.',
  price:       15.00,
)

Product.create!(
  title:       'Rubitter Stickers',
  description: 'Decorate your laptop, water bottle, or anywhere with these high-quality Rubitter-themed stickers. Perfect for any Rubitter fan.',
  price:       3.99,
)

Product.create!(
  title:       'Rubitter Keychain',
  description: 'A durable Rubitter-themed keychain that makes it easy to carry your love for Rubitter everywhere you go.',
  price:       7.49,
)

Product.create!(
  title:       'Rubitter Socks',
  description: 'Comfortable and warm Rubitter socks to keep your feet cozy while you work on your next Rubitter project.',
  price:       9.99,
)

Product.create!(
  title:       'Rubitter Poster',
  description: "Bring Rubitter to your walls with this sleek, modern poster. Ideal for any Rubitter developer's office or home.",
  price:       14.00,
)

Product.create!(
  title:       'Rubitter Tote Bag',
  description: 'Show off your Rubitter spirit with this eco-friendly, spacious tote bag. Perfect for carrying your laptop and other essentials.',
  price:       19.99,
)

Product.create!(
  title:       'Rubitter Phone Case',
  description: 'Protect your phone with a Rubitter-inspired case, designed to fit most modern smartphones while showing off your love for the language.',
  price:       16.49,
)
