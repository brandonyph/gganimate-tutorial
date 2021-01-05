#1. gganimate package 
#2. transition_*()
#3. ease_aes() 
#4. enter_* and exit_* animation configuration 
#5. COVID_19 data animation

#-------------------------------------
#  1. gganimate package 
#------------------------------------

library(gganimate)

#> Loading required package: ggplot2

#gganimate extends the grammar of graphics as implemented by ggplot2 to include the description of animation.
#It does this by providing a range of new grammar classes that can be added to the plot object
#in order to customise how it should change with time.

#transition_*() defines how the data should be spread out and how it relates to itself across time.
#view_*() defines how the positional scales should change along the animation.
#shadow_*() defines how data from other points in time should be presented in the given point in time.
#enter_*()/exit_*() defines how new data should appear and how old data should disappear during the course of the animation.
#ease_aes() defines how different aesthetics should be eased during transitions.

# We'll start with a static plot
p <- ggplot(iris, aes(x = Petal.Width, y = Petal.Length)) +
  geom_point()

#aes(colour = Species), size = 2

plot(p)

#------------------------------------
# 2. transition_states()
#------------------------------------

anim <- p +
  transition_states(Species,
                    transition_length = 2,
                    state_length = 1)

#states
#   The unquoted name of the column holding the state levels in the data.
#transition_length
#   The relative length of the transition. Will be recycled to match the number of states in the data
#state_length
#   The relative length of the pause at the states. Will be recycled to match the number of states in the data

#--------------------------------------------
# 3. ease_aes(), Control easing of aesthetics
#--------------------------------------------

anim +
  ease_aes(y = 'bounce-out') # Sets special ease for y aesthetic

##ease_aes() animation type
#quadratic Models a power-of-2 function
#cubic Models a power-of-3 function
#quartic Models a power-of-4 function
#quintic Models a power-of-5 function
#sine Models a sine function
#circular Models a pi/2 circle arc
#exponential Models an exponential function
#elastic Models an elastic release of energy
#back Models a pullback and relase
#bounce Models the bouncing of a ball

#modifier
#-in The easing function is applied as-is
#-out The easing function is applied in reverse
#-in-out The first half of the transition it is applied as-is, while in the last half it is reversed

anim +
  ggtitle('Now showing {closest_state}',
          subtitle = 'Frame {frame} of {nframes}')

#-------------------------------------
# 4. Enter and exit animation
#-------------------------------------
#https://rdrr.io/github/thomasp85/gganimate/man/enter_exit.html

anim2 <- ggplot(iris, aes(x = Petal.Width, y = Petal.Length)) + 
  geom_point(aes(colour = Species)) + 
  transition_states(Species,
                    transition_length = 2,
                    state_length = 1)

anim2 +
  enter_fade() +
  exit_shrink()

anim2 +
  enter_fade() + enter_drift(x_mod = -1) +
  exit_shrink() + exit_drift(x_mod = 5)

#-------------------------------------
# Now lets combined all that we know
#------------------------------------
#Example 1 
ggplot(mtcars, aes(factor(cyl), mpg)) + 
  geom_boxplot() + 
  # Here comes the gganimate code
  transition_states(
    gear,
    transition_length = 2,
    state_length = 1
  ) +
  enter_fade() + 
  exit_shrink() +
  ease_aes('sine-in-out')


#Example 2
#install.packages("gapminder")
library(gapminder)

ggplot(gapminder,aes(x = gdpPercap, y=lifeExp, size = pop, colour = country)) +
  geom_point(show.legend = FALSE, alpha = 0.7) +
  scale_color_viridis_d() +
  scale_size(range = c(2, 12)) +
  scale_x_log10() +
  labs(x = "GDP per capita", y = "Life expectancy")+ 
  transition_time(year) +
  labs(title = "Year: {frame_time}")

###########################################################################################

#----------------------------------------------------------
# 5. Practical Data Plotting - Covid 19 Dataset
#----------------------------------------------------------
#https://www.ecdc.europa.eu/en/publications-data/download-todays-data-geographic-distribution-covid-19-cases-worldwide

library(readxl)

COVID_19 <-
  read_excel(
    "COVID-19-geographic-disbtribution-worldwide-2020-04-19.xlsx"
  )

dim(COVID_19)
#11768    10

str(COVID_19)
#tibble [11,768 x 10] (S3: tbl_df/tbl/data.frame)
#$ dateRep                : POSIXct[1:11768], format: "2020-04-19" "2020-04-18" "2020-04-17" "2020-04-16" ...
#$ day                    : num [1:11768] 19 18 17 16 15 14 13 12 11 10 ...
#$ month                  : num [1:11768] 4 4 4 4 4 4 4 4 4 4 ...
#$ year                   : num [1:11768] 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 ...
#$ cases                  : num [1:11768] 63 51 10 70 49 58 52 34 37 61 ...
#$ deaths                 : num [1:11768] 0 1 4 2 2 3 0 3 0 1 ...
#$ countriesAndTerritories: chr [1:11768] "Afghanistan" "Afghanistan" "Afghanistan" "Afghanistan" ...
#$ geoId                  : chr [1:11768] "AF" "AF" "AF" "AF" ...
#$ countryterritoryCode   : chr [1:11768] "AFG" "AFG" "AFG" "AFG" ...
#$ popData2018            : num [1:11768] 37172386 37172386 37172386 37172386 37172386 ...
#########################################################################################################

library(dplyr)

Totalcases_in_All_Countries <-
  COVID_19 %>% group_by(countriesAndTerritories) %>% summarise(Cases = sum(cases))

COVID_19s <-
  COVID_19 %>% group_by(countryterritoryCode) %>% filter(sum(cases) > 30000)

COVID_19s <- COVID_19s[COVID_19s$dateRep>'2020-01-01',]

COVID_19s1 <- COVID_19s %>%
              group_by(countryterritoryCode) %>%
              arrange(dateRep) %>% 
              mutate(cum_deaths = cumsum(deaths))

COVID_19s2 <- COVID_19s1 %>%
              group_by(countryterritoryCode) %>%
              arrange(dateRep) %>% 
              mutate(cum_cases = cumsum(cases))

COVID_19s3 <- COVID_19s2 %>%
              group_by(countryterritoryCode) %>%
              arrange(dateRep) %>% 
              mutate(deathrate = cum_deaths/cum_cases*100)

COVID_19s3$deathrate[is.nan(COVID_19s3$deathrate)] <- 0
COVID_19s3$deathrate[is.infinite(COVID_19s3$deathrate)] <- 0
COVID_19s3$deathrate[COVID_19s3$deathrate>20] <- 0

COVID_19s3$countriesAndTerritories <- factor(COVID_19s2$countriesAndTerritories,
                                             levels = unique(COVID_19s2$countriesAndTerritories[COVID_19s2$dateRep>"2020-04-19"])[order(COVID_19s2$cum_cases[COVID_19s2$dateRep>"2020-04-19"])])
            

#Transition reveal only works in geom_line() and geom_area()
cv2 <- ggplot(COVID_19s3, aes(x = dateRep, y = cases))
cv2 + geom_line(aes(color = countryterritoryCode)) + geom_point()
cv2 + geom_line(aes(color = countryterritoryCode)) + geom_point() + transition_reveal(dateRep) 


cv3 <- ggplot(COVID_19s3, aes(x = countriesAndTerritories, y = cum_cases))
cv4 <- cv3 + geom_col(aes(fill = deathrate)) + coord_flip() + transition_time(dateRep) + scale_y_log10() +
        ggtitle('Now showing {frame_time}',subtitle = 'Frame {frame} of {nframes}') + theme(text = element_text(size=20))

animate(cv4, nframes= 240, fps=12, height = 480, width = 480)

anim_save("Covid Total Animation.mp4", animation = last_animation())


