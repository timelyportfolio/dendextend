% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/common_subtrees.R
\name{rank_values_with_clusters}
\alias{rank_values_with_clusters}
\title{Rank a vector based on clusters}
\usage{
rank_values_with_clusters(x, ignore0 = FALSE, ...)
}
\arguments{
\item{x}{numeric vector}

\item{ignore0}{logical (FALSE). If TRUE, will ignore the 0's in the vector}

\item{...}{not used}
}
\value{
an integer vector with the number of unique values
as the number of uniques in the original vector.
And the values are ranked from 1 (in the beginning of the vector)
to the number of unique clusters.
}
\description{
Rank a vector based on clusters
}
\examples{
rank_values_with_clusters(c(1,2,3))
rank_values_with_clusters(c(1,1,3))
rank_values_with_clusters(c(0.1,0.1,3000))
rank_values_with_clusters(c(3,1,2))
rank_values_with_clusters(c(1,3,3,3,3,3,3,4,2,2))

rank_values_with_clusters(c(3,1,2), ignore0 = TRUE)
rank_values_with_clusters(c(3,1,2), ignore0 = FALSE)
rank_values_with_clusters(c(3,1,0,2), ignore0 = TRUE)
rank_values_with_clusters(c(3,1,0,2), ignore0 = FALSE)
}

