puts "Seeding stadiums…"

stadiums = [
  { mlb_venue_id: 2,    name: "Oriole Park at Camden Yards",  team_name: "Baltimore Orioles",    city: "Baltimore",     state: "MD", lat: 39.283878,  lng: -76.621827,  capacity: 45971, opened_year: 1992 },
  { mlb_venue_id: 3,    name: "Fenway Park",                   team_name: "Boston Red Sox",       city: "Boston",        state: "MA", lat: 42.346612,  lng: -71.097441,  capacity: 37755, opened_year: 1912 },
  { mlb_venue_id: 4,    name: "Guaranteed Rate Field",         team_name: "Chicago White Sox",    city: "Chicago",       state: "IL", lat: 41.830067,  lng: -87.633833,  capacity: 40615, opened_year: 1991 },
  { mlb_venue_id: 5,    name: "Progressive Field",             team_name: "Cleveland Guardians",  city: "Cleveland",     state: "OH", lat: 41.495697,  lng: -81.685542,  capacity: 34830, opened_year: 1994 },
  { mlb_venue_id: 7,    name: "Kauffman Stadium",              team_name: "Kansas City Royals",   city: "Kansas City",   state: "MO", lat: 39.051595,  lng: -94.480483,  capacity: 37903, opened_year: 1973 },
  { mlb_venue_id: 12,   name: "Tropicana Field",               team_name: "Tampa Bay Rays",       city: "St. Petersburg",state: "FL", lat: 27.768091,  lng: -82.653365,  capacity: 25025, opened_year: 1990 },
  { mlb_venue_id: 14,   name: "Rogers Centre",                 team_name: "Toronto Blue Jays",    city: "Toronto",       state: "ON", lat: 43.641438,  lng: -79.389353,  capacity: 49286, opened_year: 1989 },
  { mlb_venue_id: 15,   name: "Chase Field",                   team_name: "Arizona Diamondbacks", city: "Phoenix",       state: "AZ", lat: 33.445416,  lng: -112.066801, capacity: 48686, opened_year: 1998 },
  { mlb_venue_id: 17,   name: "Wrigley Field",                 team_name: "Chicago Cubs",         city: "Chicago",       state: "IL", lat: 41.948347,  lng: -87.655835,  capacity: 41268, opened_year: 1914 },
  { mlb_venue_id: 19,   name: "Coors Field",                   team_name: "Colorado Rockies",     city: "Denver",        state: "CO", lat: 39.756081,  lng: -104.994166, capacity: 46897, opened_year: 1995 },
  { mlb_venue_id: 1,    name: "Angel Stadium",                 team_name: "Los Angeles Angels",   city: "Anaheim",       state: "CA", lat: 33.800308,  lng: -117.882721, capacity: 45477, opened_year: 1966 },
  { mlb_venue_id: 22,   name: "Dodger Stadium",                team_name: "Los Angeles Dodgers",  city: "Los Angeles",   state: "CA", lat: 34.073889,  lng: -118.240000, capacity: 56000, opened_year: 1962 },
  { mlb_venue_id: 32,   name: "American Family Field",         team_name: "Milwaukee Brewers",    city: "Milwaukee",     state: "WI", lat: 43.028162,  lng: -87.971267,  capacity: 41900, opened_year: 2001 },
  { mlb_venue_id: 31,   name: "PNC Park",                      team_name: "Pittsburgh Pirates",   city: "Pittsburgh",    state: "PA", lat: 40.446857,  lng: -80.005673,  capacity: 38362, opened_year: 2001 },
  { mlb_venue_id: 680,  name: "T-Mobile Park",                 team_name: "Seattle Mariners",     city: "Seattle",       state: "WA", lat: 47.591527,  lng: -122.332604, capacity: 47929, opened_year: 1999 },
  { mlb_venue_id: 2392, name: "Minute Maid Park",              team_name: "Houston Astros",       city: "Houston",       state: "TX", lat: 29.756967,  lng: -95.355491,  capacity: 41168, opened_year: 2000 },
  { mlb_venue_id: 2394, name: "Comerica Park",                 team_name: "Detroit Tigers",       city: "Detroit",       state: "MI", lat: 42.338947,  lng: -83.048561,  capacity: 41083, opened_year: 2000 },
  { mlb_venue_id: 2395, name: "Oracle Park",                   team_name: "San Francisco Giants", city: "San Francisco", state: "CA", lat: 37.778598,  lng: -122.389229, capacity: 41915, opened_year: 2000 },
  { mlb_venue_id: 2602, name: "Great American Ball Park",      team_name: "Cincinnati Reds",      city: "Cincinnati",    state: "OH", lat: 39.097414,  lng: -84.507047,  capacity: 42319, opened_year: 2003 },
  { mlb_venue_id: 2680, name: "Petco Park",                    team_name: "San Diego Padres",     city: "San Diego",     state: "CA", lat: 32.707683,  lng: -117.157443, capacity: 40209, opened_year: 2004 },
  { mlb_venue_id: 2681, name: "Citizens Bank Park",            team_name: "Philadelphia Phillies",city: "Philadelphia",  state: "PA", lat: 39.905793,  lng: -75.166184,  capacity: 42901, opened_year: 2004 },
  { mlb_venue_id: 2889, name: "Busch Stadium",                 team_name: "St. Louis Cardinals",  city: "St. Louis",     state: "MO", lat: 38.622685,  lng: -90.192735,  capacity: 44494, opened_year: 2006 },
  { mlb_venue_id: 3289, name: "Citi Field",                    team_name: "New York Mets",        city: "Flushing",      state: "NY", lat: 40.756822,  lng: -73.845839,  capacity: 41922, opened_year: 2009 },
  { mlb_venue_id: 3309, name: "Nationals Park",                team_name: "Washington Nationals", city: "Washington",    state: "DC", lat: 38.873014,  lng: -77.007516,  capacity: 41313, opened_year: 2008 },
  { mlb_venue_id: 3312, name: "Target Field",                  team_name: "Minnesota Twins",      city: "Minneapolis",   state: "MN", lat: 44.981728,  lng: -93.278114,  capacity: 38544, opened_year: 2010 },
  { mlb_venue_id: 3313, name: "Yankee Stadium",                team_name: "New York Yankees",     city: "Bronx",         state: "NY", lat: 40.829659,  lng: -73.926186,  capacity: 54251, opened_year: 2009 },
  { mlb_venue_id: 4169, name: "loanDepot park",                team_name: "Miami Marlins",        city: "Miami",         state: "FL", lat: 25.778017,  lng: -80.219768,  capacity: 37446, opened_year: 2012 },
  { mlb_venue_id: 4705, name: "Truist Park",                   team_name: "Atlanta Braves",       city: "Cumberland",    state: "GA", lat: 33.890528,  lng: -84.467806,  capacity: 41084, opened_year: 2017 },
  { mlb_venue_id: 5325, name: "Globe Life Field",              team_name: "Texas Rangers",        city: "Arlington",     state: "TX", lat: 32.747272,  lng: -97.082535,  capacity: 40518, opened_year: 2020 },
  { mlb_venue_id: 2529, name: "Sutter Health Park",            team_name: "Athletics",            city: "West Sacramento",state: "CA", lat: 38.580598,  lng: -121.500267, capacity: 14014, opened_year: 2000 },
]

stadiums.each do |attrs|
  Stadium.find_or_create_by!(mlb_venue_id: attrs[:mlb_venue_id]) do |s|
    s.name        = attrs[:name]
    s.team_name   = attrs[:team_name]
    s.city        = attrs[:city]
    s.state       = attrs[:state]
    s.lat         = attrs[:lat]
    s.lng         = attrs[:lng]
    s.capacity    = attrs[:capacity]
    s.opened_year = attrs[:opened_year]
    s.active      = true
  end
end

puts "Seeded #{Stadium.count} stadiums."
