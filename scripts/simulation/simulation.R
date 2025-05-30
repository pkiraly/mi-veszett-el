#' https://web.stanford.edu/class/bios221/labs/simulation/lab_3_simulation.html
#' 
library(tidyverse)

vecpoisson = rpois(100,5)
hist(vecpoisson)

ggplot(data.frame(vecpoisson), aes(vecpoisson)) +
  geom_histogram(aes(y=..density..))

mean(vecpoisson)

#' the sum of exponentials gives a gamma distribution
#' rexp: random generation for the exponential distribution
#'   n = number of observations
#'   rate	= vector of rates
reps <- 50000
nexps <- 5
rate <- 0.1
set.seed(0)

rexp(n=nexps, rate=rate)
sum(rexp(n=nexps, rate=rate))

system.time(
  x1 <- replicate(reps, sum(rexp(n=nexps, rate=rate)))
) # replicate
x1
head(x1)

#' dgamma: density for the Gamma distribution
#'   shape, scale = shape and scale parameters. 
#'                  Must be positive, scale strictly.
ggplot(data.frame(x1), aes(x1)) + 
  geom_histogram(aes(y=..density..)) +
  stat_function(
    fun = function(x)dgamma(x, shape=nexps, scale=1/rate),
    color = "red", 
    size = 2
  )

#' sapply(): simple apply
set.seed(0)
system.time(
  x1 <- sapply(
          1:reps,
          function(i){
            sum(rexp(n=nexps, rate=rate))
          }
        )
)
x1

#' lapply: list apply, returns a list
#' 
set.seed(0)
system.time(
  x1 <- lapply(
          1:reps,
          function(i){
            sum(rexp(n=nexps, rate=rate))
          }
        )
)
head(x1)

#' apply: apply on a matrix
#' apply(X, MARGIN, FUN)
#'   MARGIN == 2: apply function on columns
#' -> create 5 rows, and sums each columns, giving in total 50000 numbers
set.seed(0)
system.time(
  x1 <- apply(
          # 5 rows, 50000 cols
          matrix(rexp(n=nexps*reps, rate=rate), nrow=nexps),
          2,
          sum
        )
)
x1

#' using colSums
set.seed(0)
system.time(
  x1 <- colSums(
          matrix(rexp(n=nexps*reps, rate=rate), nrow=nexps)
        )
)

#' If you have a multi-core processor, sometimes you can speed things up
#' by taking advantage of parallelization. In the package parallel is the
#' function mclapply() which acts very similarly to lapply(). By default, this
#' uses only a single processor. You can change mc.cores if you have more cores.
require(parallel)
set.seed(0)
system.time(
  x1 <- mclapply(
          1:reps,
          function(i){
            sum(rexp(n=nexps, rate=rate))
          },
          mc.cores = 4
        )
)

#' Generating normal random variables
samples = rnorm(1000, 0, 1)
samples
load("data_raw/simulation/mystery_samples.RData")
head(samples)

ggplot(data.frame(samples), aes(samples)) + 
  geom_histogram(aes(y=..density..)) +
  stat_function(
    fun = function(x)dnorm(x, mean=mean(samples), sd=sd(samples)),
    color = "red", 
    size = 2
  )


pop1=rnorm(2000000)
pop2=rnorm(1000000, 1, 2)
combined = c(pop1, pop2)
data2plot = data.frame(data=c(combined, pop1, pop2), 
                       labels=rep(c("combined", "pop1", "pop2"), c(3e6, 2e6, 1e6)))
plt = ggplot(data2plot, aes(x=data)) + 
  stat_bin(aes(fill = labels),
           position="identity",
           binwidth=0.25, alpha=0.5) + 
  theme_bw()
plt

#' Generating Random DNA strings
#' 
require(Biostrings)

trans = matrix(c(0.2, 0.2, 0.19, 0.1, 0.27, 0.34, 0.31, 0.34, 0.39, 
               0.24, 0.35, 0.36, 0.14, 0.22, 0.15, 0.20),nrow=4) 
dimnames(trans) = list(c("A", "C", "G", "T"), c("A", "C", "G", "T"))
trans

#' Generate two multivariate normal clusters
require(MASS)
Sigma = matrix(c(5,3,3,2),2,2)
ex1 = mvrnorm(100000, rep(0, 2), Sigma)
Sigma = matrix(c(9, -5, -1, 5), 2, 2)
ex2 = mvrnorm(n=100000, rep(3, 2), Sigma)
df2 <- data.frame(ex2)
head(df2)
df2 %>% 
  ggplot(aes(x = X1, y = X2)) +
  geom_point(alpha = 0.1) + 
  geom_density2d()

#' Monte carlo simulation
#' 
isEvent = function(numDice, numSides, targetValue, numTrials){
  apply(
    matrix(
      sample(1:numSides, numDice*numTrials, replace=TRUE),
      nrow=numDice
    ),
    2,
    sum
  ) >= targetValue
}

set.seed(0)
#try 5 trials
outcomes = isEvent(2, 6, 7, 5)
mean(outcomes)

set.seed(0)
outcomes = isEvent(2, 6, 7, 10000)
mean(outcomes)

require(parallel)
isEventPar = function(numDice, numSides, targetValue, trialIndices){
  sapply(1:length(trialIndices), 
         function(x) sum(sample(1:numSides, numDice, replace=TRUE)) >= targetValue)
}

set.seed(0)
outcomes = pvec(1:10000, function(x) isEventPar(2, 6, 7, x))
mean(outcomes)

#' Gamma mixture of poissons
#' Generate the means of the poisson distribution by sampling
#' from a gamma distribution:
  
lambdas = rgamma(100, shape=2, scale=3)
samples = rep(0, 100)
for (i in 1:100)
  samples[i] = rpois(1, lambdas[i])

#' Power calculation
compute_power = function(n, sigma, numTrials){
  sampa = matrix(rnorm(n*numTrials, 1, sigma), ncol=numTrials)
  sampb = matrix(rnorm(n*numTrials, 2, sigma), ncol=numTrials)
  statistics = (
    apply(sampa, 2, mean) - apply(sampb, 2, mean)
    ) / sqrt(2 * sigma ^ 2 / n)
  return (mean(abs(statistics) >= qnorm(0.975)))
}

set.seed(0)
compute_power(3, 0.5, 10000)

compute_power(4, 0.5, 10000)

#' How to identify the distribution of the given data using r
#' https://stackoverflow.com/questions/31741742/how-to-identify-the-distribution-of-the-given-data-using-r
#'
x <-  c(37.50,46.79,48.30,46.04,43.40,39.25,38.49,49.51,40.38,36.98,40.00,38.49,37.74,47.92,44.53,44.91,44.91,40.00,41.51,47.92,36.98,43.40)

library(fitdistrplus)
descdist(x, discrete = FALSE)

normal_dist <- fitdist(x, "norm")
normal_dist
plot(normal_dist)

#---
hist(x, freq = FALSE)
lines(density(x))

#' What distribution does my data follow?
#' https://stats.stackexchange.com/questions/58220/what-distribution-does-my-data-follow
#' 

x <- c(1528L, 285L, 87138L, 302L, 115L, 416L, 8940L, 19438L, 165820L, 540L, 1653L, 1527L, 974L, 12999L, 226L, 190L, 306L, 189L, 138542L, 3049L, 129067L, 21806L, 456L, 22745L, 198L, 44568L, 29355L, 17163L, 294L, 4218L, 3672L, 10100L, 290L, 8341L, 128L, 11263L, 1495243L, 1699L, 247L, 249L, 300L, 351L, 608L, 186684L, 524026L, 1392L, 396L, 298L, 1063L, 11102L, 6684L, 6546L, 289L, 465L, 261L, 175L, 356L, 61652L, 236L, 74795L, 64982L, 294L, 95221L, 322L, 38892L, 2146L, 59347L, 2118L, 310801L, 277964L, 205679L, 5980L, 66102L, 36495L, 580277L, 27600L, 509L, 21795L, 21795L, 301L, 617L, 331L, 250L, 123501L, 144L, 347L, 121443L, 211L, 232L, 445783L, 9715L, 10308L, 1921L, 178L, 168L, 291L, 6915L, 6735L, 1008478L, 274L, 20L, 3287L, 591208L, 797L, 586L, 170613L, 938L, 3121L, 249L, 1497L, 24L, 1407L, 1217L, 1323L, 272L, 443L, 49466L, 323L, 323L, 784L, 900L, 26814L, 2452L, 214713L, 3668L, 325L, 20439L, 12304L, 261L, 137L, 379L, 2273L, 274L, 17760L, 920699L, 13L, 485644L, 1243L, 226L, 20388L, 584L, 17695L, 1477L, 242L, 280L, 253L, 17964L, 7073L, 308L, 260692L, 155L, 58136L, 16644L, 29353L, 543L, 276L, 2328L, 254L, 1392L, 272L, 480L, 219L, 60L, 2285L, 2676L, 256L, 234L, 1240L, 219714L, 102174L, 258L, 266L, 33043L, 530L, 6334L, 94047L, 293L, 536L, 48557L, 4141L, 39079L, 23259L, 2235L, 17673L, 28268L, 112L, 64824L, 127992L, 5291L, 51693L, 762L, 1070735L, 179L, 189L, 157L, 157L, 122L, 1045L, 1317L, 186L, 57901L, 456126L, 674L, 2375L, 1782L, 257L, 23L, 248L, 216L, 114L, 11662L, 107890L, 203022L, 513L, 2549L, 146L, 53331L, 1690L, 10752L, 1648611L, 148L, 611L, 198L, 443L, 10061L, 720L, 10L, 24L, 220L, 38L, 453L, 10066L, 115774L, 97713L, 7234L, 773L, 90154L, 151L, 1560L, 222L, 51558L, 214L, 948L, 208L, 1127L, 221L, 169L, 1528L, 78959L, 61566L, 88049L, 780L, 6196L, 633L, 214L, 2547L, 19088L, 119L, 561L, 112L, 17557L, 101086L, 244L, 257L, 94483L, 6189L, 236L, 248L, 966L, 117L, 333L, 278L, 553L, 568L, 356L, 731L, 25258L, 127931L, 7735L, 112717L, 395L, 12960L, 11383L, 16L, 229067L, 259076L, 311L, 366L, 2696L, 7265L, 259076L, 3551L, 7782L, 4256L, 87121L, 4971L, 4706L, 245L, 34457L, 4971L, 4706L, 245L, 34457L, 258L, 36071L, 301L, 2214L, 2231L, 247L, 537L, 301L, 2214L, 230L, 1076L, 1881L, 266L, 4371L, 88304L, 50056L, 50056L, 232L, 186336L, 48200L, 112L, 48200L, 48200L, 6236L, 82158L, 6236L, 82158L, 1331L, 713L, 89106L, 46315L, 220L, 5634L, 170601L, 588L, 1063L, 2282L, 247L, 804L, 125L, 5507L, 1271L, 2567L, 441L, 6623L, 64781L, 1545L, 240L, 2921L, 777L, 697L, 2018L, 24064L, 199L, 183L, 297L, 9010L, 16304L, 930L, 6522L, 5717L, 17L, 20L, 364418L, 58246L, 7976L, 304L, 4814L, 307L, 487L, 292016L, 6972L, 15L, 40922L, 471L, 2342L, 2248L, 23L, 2434L, 23342L, 807L, 21L, 345568L, 324L, 188L, 184L, 191L, 188L, 198L, 195L, 187L, 185L, 33968L, 1375L, 121L, 56872L, 35970L, 929L, 151L, 5526L, 156L, 2687L, 4870L, 26939L, 180L, 14623L, 265L, 261L, 30501L, 5435L, 9849L, 5496L, 1753L, 847L, 265L, 280L, 1840L, 1107L, 2174L, 18907L, 14762L, 3450L, 9648L, 1080L, 45L, 6453L, 136351L, 521L, 715L, 668L, 14550L, 1381L, 13294L, 13100L, 6354L, 6319L, 84837L, 84726L, 84702L, 2126L, 36L, 572L, 1448L, 215L, 12L, 7105L, 758L, 4694L, 29369L, 7579L, 709L, 121L, 781L, 1391L, 2166L, 160403L, 674L, 1933L, 320L, 1628L, 2346L, 2955L, 204852L, 206277L, 2408L, 2162L, 312L, 280L, 243L, 84050L, 830L, 290L, 10490L, 119392L, 182960L, 261791L, 92L, 415L, 144L, 2006L, 1172L, 1886L, 233L, 36123L, 7855L, 554L, 234L, 2292L, 21L, 132L, 142L, 3848L, 3847L, 3965L, 3431L, 2465L, 1717L, 3952L, 854L, 854L, 834L, 14608L, 172L, 7885L, 75303L, 535L, 443347L, 5478L, 782L, 9066L, 6733L, 568L, 611L, 533L, 1022L, 334L, 21628L, 295362L, 34L, 486L, 279L, 2530L, 504L, 525L, 367L, 293L, 258L, 1854L, 209L, 152L, 1139L, 398L, 3275L, 284178L, 284127L, 826L, 751L, 1814L, 398L, 1517L, 255L, 13745L, 43L, 1463L, 385L, 64L, 5279L, 885L, 1193L, 190L, 451L, 1093L, 322L, 453L, 680L, 452L, 677L, 295L, 120L, 12184L, 250L, 1165L, 476L, 211L, 4437L, 7310L, 778L, 260L, 855L, 353L, 97L, 34L, 87L, 137L, 101L, 416L, 130L, 148L, 832L, 187L, 291L, 4050L, 14569L, 271L, 1968L, 6553L, 2535L, 227L, 202L, 647L, 266L, 2681L, 106L, 158L, 257L, 234L, 1726L, 34L, 465L, 436L, 245L, 245L, 2790L, 104L, 1283L, 44416L, 142L, 13617L, 232L, 171L, 221L, 719L, 176L, 5838L, 37488L, 12214L, 3780L, 5556L, 5368L, 106L, 246L, 101L, 158L, 10743L, 5L, 46478L, 5286L, 9866L, 32593L, 174L, 298L, 19617L, 19350L, 230L, 78449L, 78414L, 78413L, 78413L, 6260L, 6260L, 209L, 2552L, 522L, 178L, 140L, 173046L, 299L, 265L, 132360L, 132252L, 4821L, 4755L, 197L, 567L, 113L, 30314L, 7006L, 10L, 30L, 55281L, 8263L, 8244L, 
       8142L, 568L, 1592L, 1750L, 628L, 60304L, 212553L, 51393L, 222L, 13471L, 3423L, 306L, 325L, 2650L, 74796L, 37807L, 103751L, 6924L, 6727L, 667L, 657L, 752L, 546L, 1860L, 230L, 217L, 1422L, 347L, 341055L, 4510L, 4398L, 179670L, 796L, 1210L, 2579L, 250L, 273L, 407L, 192049L, 236L, 96084L, 5808L, 7546L, 10646L, 197L, 188L, 19L, 167877L, 200509L, 429L, 632L, 495L, 471L, 2578L, 251L, 198L, 175L, 19161L, 289L, 20718L, 201L, 937L, 283L, 4829L, 4776L, 5949L, 856907L, 2747L, 2761L, 3150L, 3142L, 68031L, 187666L, 255211L, 255231L, 6581L, 392991L, 858L, 115L, 141L, 85629L, 125433L, 6850L, 6684L, 23L, 529L, 562L, 216L, 1450L, 838L, 3335L, 1446L, 178L, 130101L, 239L, 1838L, 286L, 289L, 68974L, 757L, 764L, 218L, 207L, 3485L, 16597L, 236L, 1387L, 2121L, 2122L, 957L, 199899L, 409803L, 367877L, 1650L, 116710L, 5662L, 12497L, 613889L, 10182L, 260L, 9654L, 422947L, 294L, 284L, 996L, 1444L, 2373L, 308L, 1522L, 288L, 937L, 291L, 93L, 17629L, 5151L, 184L, 161L, 3273L, 1090L, 179840L, 1294L, 922L, 826L, 725L, 252L, 715L, 6116L, 259L, 6171L, 198L, 5610L, 5679L, 862L, 332L, 1324L, 536L, 98737L, 316L, 5608L, 5526L, 404L, 255L, 251L, 14067L, 3360L, 3623L, 8920L, 288L, 447L, 453L, 1604687L, 115L, 127L, 127L, 2398L, 2396L, 2396L, 2398L, 2396L, 2397L, 154L, 154L, 154L, 154L, 887L, 636L, 227L, 227L, 354L, 7150L, 30227L, 546013L, 545979L, 251L, 171647L, 252L, 583L, 593L, 10222L, 2660L, 1864L, 2884L, 1577L, 1304L, 337L, 2642L, 2462L, 280L, 284L, 3463L, 288L, 288L, 540L, 287L, 526L, 721L, 1015L, 74071L, 6338L, 1590L, 582L, 765L, 291L, 983L, 158L, 625L, 581L, 350L, 6896L, 13567L, 20261L, 4781L, 1025L, 722L, 721L, 1618L, 1799L, 987L, 6373L, 733L, 5648L, 987L, 1010L, 985L, 920L, 920L, 4696L, 1154L, 1132L, 927L, 4546L, 692L, 702L, 301L, 305L, 316L, 313L, 801L, 788L, 14624L, 14624L, 9778L, 9778L, 9778L, 9778L, 757L, 275L, 1480L, 610L, 68495L, 1152L, 1155L, 323L, 312L, 303L, 298L, 1641L, 1607L, 1645L, 616L, 1002L, 1034L, 1022L, 1030L, 1030L, 1027L, 1027L, 934L, 960L, 47L, 44L, 1935L, 1925L, 43L, 47L, 1933L, 1898L, 938L, 830L, 286L, 287L, 807L, 807L, 741L, 628L, 482L, 500L, 480L, 431L, 287L, 298L, 227L, 968L, 961L, 943L, 932L, 704L, 420L, 548L, 3612L, 1723L, 780L, 337L, 780L, 527L, 528L, 499L, 679L, 308L, 1104L, 314L, 1607L, 990L, 1156L, 562L, 299L, 16L, 20L, 287L, 581L, 1710L, 1859L, 988L, 962L, 834L, 1138L, 363L, 294L, 2678L, 362L, 539L, 295L, 996L, 977L, 988L, 39L, 762L, 579L, 595L, 405L, 1001L, 1002L, 555L, 1102L, 54L, 1283L, 347L, 1384L, 603L, 307L, 306L, 302L, 302L, 288L, 288L, 286L, 292L, 529L, 56844L, 1986L, 503L, 751L, 3977L, 367L, 4817L, 4631L, 4609L, 4579L, 937L, 402L, 257L, 570L, 1156L, 3297L, 3948L, 4527L, 3119L, 15227L, 3893L, 538L, 802L, 5128L, 595L, 522L, 1346L, 449L, 443L, 323L, 372L, 369L, 307L, 246L, 260L, 342L, 283L, 963L, 751L, 108L, 280L, 320L, 287L, 285L, 283L, 529L, 536L, 298L, 29427L, 29413L, 761L, 249L, 255L, 304L, 297L, 256L, 119L, 288L, 564L, 234L, 226L, 530L, 766L, 223L, 5858L, 5568L, 481L, 462L, 8692L, 498L, 330L, 7604L, 15L, 121738L, 121833L, 826L, 760L, 208937L, 1598L, 1166L, 446L, 85598L, 513L, 84897L, 50239L, 308L, 1351L, 283L, 7100L, 7101L, 321L, 1019L, 287L, 253L, 634L, 629L, 628L, 678L, 1391L, 1147L, 853L, 287L, 1174L, 287L, 197145L, 197116L, 147L, 147L, 712L, 274L, 283L, 907L, 434L, 1164L, 30L, 599L, 577L, 315L, 1423L, 1250L, 30L, 1502L, 296L, 348L, 617L, 339L, 328L, 123L, 338L, 332L, 47133L, 288L, 340L, 1524L, 1049L, 1072L, 1031L, 1059L, 1038L, 989L, 52L, 54L, 986L, 46L, 1202L, 1272L, 43L, 785L, 761L, 16924L, 289L, 264L, 453L, 365L, 356L, 280L, 16520L, 281L, 255L, 244L, 642L, 1003L, 951L, 921L, 1011L, 45L, 932L, 973L, 39L, 40L, 159L, 566L, 49L, 1161L, 50L, 200L, 215L, 361L, 377L, 980L, 935L, 882L, 281L, 280L, 1025L, 319L, 690L, 284L, 271L, 276L, 286L, 371L, 324L, 304L, 311L, 341L, 603L, 11566L, 270L, 286L, 342L, 326L, 11018L, 282L, 271L, 286L, 586L, 604L, 750L, 608L, 523L, 506L, 
       3303L, 1079797L, 1079811L, 530L, 2631L, 882L, 628L, 30L, 11905L, 12966L, 390995L, 322353L, 1763L, 1755L, 709L, 713L, 365L, 351L, 205L, 393L, 284L, 39417L, 320L, 322L, 8039L, 995L, 625L, 785L, 298L, 518L, 467L, 1050L, 329L, 141345L, 55566L, 40318L, 287L, 220L, 309346L, 220L, 215314L, 304L, 296L, 4301L, 4311L, 1543L, 1549L, 2876L, 2894L, 287L, 290L, 215L, 605L, 577L, 254L, 1330L, 1863L, 140L, 328L, 284L, 291L, 283L, 1701L, 1696L, 519L, 499L, 2440007L, 289L, 294L, 311L, 324L, 4793L, 4808L, 249L, 205L, 219L, 
       638L, 2653L, 2648L, 351L, 323L, 1056L, 327L, 794L, 1491L, 284L, 289L, 220L, 765L, 565L, 808L, 832L, 772L, 41668L, 42307L, 6843L, 6612L, 6598L, 241164L, 531L, 554L, 1246L, 459L, 971504L, 805L, 2615L, 2290L, 2086L, 2063L, 2685L, 2704L, 275L, 461L, 458L, 317L, 889L, 335L, 974L, 959L, 253142L, 257L, 250L, 282L, 293L, 666L, 4991L, 287L, 588L, 555L, 3585L, 3195L, 481L, 2405L, 135266L, 571L, 1805L, 365L, 340L, 232L, 224L, 298L, 3682L, 3677L, 577L, 571L, 288L, 297L, 293L, 291L, 256L, 214L, 1257L, 1271L, 65471L, 65471L, 65476L, 65476L, 4680L, 4675L, 339L, 329L, 284L, 288L, 4859L, 4851L, 2534L, 24222L, 330684L, 330684L, 2116L, 282L, 412L, 429L, 2324L, 1978L, 502L, 286L, 943149L, 256L, 288L, 286L, 1098L, 1125L, 442L, 240L, 182L, 2617L, 1068L, 25204L, 170L, 418L, 1867L, 8989L, 1804L, 1240L, 6610L, 1237L, 1750L, 1565L, 1565L, 3662L, 1803L, 218L, 172L, 780L, 1418L, 2390L, 7514L, 23214L, 1464L, 1060L, 1503L, 308802L, 308357L, 21691L, 298817L, 289875L, 4442L, 289284L, 235L, 456L, 676L, 897L, 289109L, 1865L, 288030L, 287899L, 287767L, 287635L, 286639L, 286509L, 286157L, 1427L, 2958L, 4340L, 5646L, 282469L, 7016L, 279353L, 278568L, 316L, 558L, 3501L, 1630L, 278443L, 1360L, 828L, 1089L, 278430L, 278299L, 278169L, 278035L, 277671L, 277541L, 277400L, 277277L, 276567L, 285L, 555L, 834L, 1084L, 1355L, 5249L, 14776L, 1441L, 755L, 755L, 70418L, 3135L, 1026L, 1497L, 949663L, 68L, 526058L, 1692L, 150L, 48370L, 4207L, 4088L, 197551L, 197109L, 196891L, 196634L, 2960L, 194319L, 194037L, 3008L, 3927L, 178762L, 178567L, 403L, 178124L, 2590L, 177405L, 177179L, 301L, 328L, 390685L, 390683L, 575L, 1049L, 819L, 367L, 289L, 277L, 390L, 301L, 318L, 3806L, 3778L, 3699L, 3691L)
x
descdist(x, boot=1000)
