# Copyright (C) Tal Galili
#
# This file is part of dendextend.
#
# dendextend is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# dendextend is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with dendextend.  If not, see <http://www.gnu.org/licenses/>.



#' @title Rotate tree objects based on label's order
#' @export
#' @description Rotates, flip and sort the branches of a tree object (dendrogram, hclust) based on a vector of labels order
#' @aliases 
#' rotate.default
#' rotate.dendrogram
#' rotate.hclust
#' rotate.phylo
#' sort.hclust
#' sort.dendrogram
#' rev.hclust
#' @usage
#' rotate(x, order, ...)
#' 
#' \method{rotate}{dendrogram}(x, order, ...)
#' 
#' \method{rotate}{hclust}(x, order, ...)
#' 
#' \method{rotate}{phylo}(x, ...)
#' 
#' \method{rev}{hclust}(x, ...)
#' 
#' \method{sort}{dendrogram}(x, decreasing=FALSE, ...)
#' 
#' \method{sort}{hclust}(x, decreasing=FALSE, ...)
#' 
#' @param x a tree object (either a \code{dendrogram} or \code{hclust})
#' @param order Either numeric or character vector.
#' Is numeric: it is a numeric vector with the order of the value to be 
#' assigned to object's label. The numbers say are just like when you use \link{order}:
#' which of the items on the tree-plot should be "first" (e.g: most left),
#' second etc. (this is relevant only to \code{rotate})
#' Is character: it must be a vector with the content of labels(x), in the 
#' order we'd like to have the new tree.
#' @param decreasing logical. Should the sort be increasing or decreasing? Not available for partial sorting. (relevant only to \code{sort})
#' @param ... parameters passed (for example, in case of sort)
#' @details 
#' The motivation for this function came from the function 
#' \code{\link{order.dendrogram}} NOT being very intuitive.
#' What \code{rotate} aims to do is give a simple tree rotation function which 
#' is based on the order which the user would like to see the tree rotated by 
#' (just as \code{\link{order}} works for numeric vectors).
#' 
#' \code{\link{rev.dendrogram}} is part of base R, and returns the tree object
#' after rotating it so that the order of the labels is reversed.
#' Here we added an S3 method for hclust objects.
#' 
#' The \code{sort} methods sort the labels of the tree (using \code{order}) 
#' and then attempts to rotate the tree to fit that order.
#' 
#' The hclust method of "\code{rotate}" works by first changing the object into
#' dendrogram, performing the rotation, and then changing it back to hclust.
#' Special care is taken in preserving some of the properties of the hclust 
#' object.
#' 
#' The {ape} package has its own \code{\link[ape]{rotate}}({ape}) function 
#' (Which is sadly not S3, so cannot be easily connected with the 
#' current implementation).  Still, there is an S3 plug that makes sure people 
#' loading first ape and then dendextend will still be able to 
#' use \code{rotate} without a problem.
#' Notice that if you will first load {ape} and only then {dendextend}, 
#' using "rotate" will fail with the error: "Error in rotate(dend, ____) :
#'  object "phy" is not of class "phylo"" - this is because rotate in ape 
#'  is not S3 and will fail to find the rotate.dendrogram function.  
#'  In such a case simply run \code{unloadNamespace("ape")}. Or, you can run:
#'  \code{unloadNamespace("dendextend"); attachNamespace("dendextend")}
#'  The solution for this is that if you have {ape} installed on your machine,
#'  It will be loaded when you load {dendextend} (but after it).
#'  This way, \code{rotate} will work fine for both dendrogram AND phylo 
#'  objects.
#'  
#' @return A rotated tree object
#' @seealso \code{\link{order.dendrogram}},  \code{\link{order}}, 
#' \code{\link{rev.dendrogram}}, \code{\link[ape]{rotate}} ({ape})
#' @examples
#' hc <- hclust(dist(USArrests[c(1,6,13,20, 23),]), "ave")
#' dend <- as.dendrogram(hc)
#' 
#' # For dendrogram objects:
#' labels_colors(dend) <- rainbow(nleaves(dend)) 
#' # let's color the labels to make the followup of the rotation easier
#' par(mfrow = c(1,2))
#' plot(dend, main = "Original tree") 
#' plot(rotate(dend, c(2:5,1)), main = 
#' "Rotates the left most leaf \n into the right side of the tree")
#' par(mfrow = c(1,2))
#' plot(dend, main = "Original tree") 
#' plot(sort(dend), main = "Sorts the labels by alphabetical order \n 
#' and rotates the tree to give the best fit possible")
#' par(mfrow = c(1,2))
#' plot(dend, main = "Original tree") 
#' plot(flip(dend), main = "Flips the order of the tree labels")
#' 
#' # For hclust objects:
#' plot(hc) 
#' plot(rotate(hc, c(2:5,1)), main = "Rotates the left most leaf \n 
#' into the right side of the tree")
#' 
rotate <- function(x, order,...) UseMethod("rotate")

#' @export
rotate.default <- function(x,...) stop("object x must be a dendrogram or hclust object")

#' @S3method rotate dendrogram
rotate.dendrogram <- function(x, order,...)
{
   if(missing(order)) { # if order is missing - return the same tree.
      warning("'order' parameter is missing, returning the tree as it was.")
      return(x)  
   }

   
   if(!is.numeric(order)) {
      order <- as.character(order)
      if(length(intersect(order, labels(x))) != nleaves(x)) {
         stop("'order' either be numeric, or a vector with ALL of the labels (in the order you want them to be)")
      }
      # order has all the labels, now, let's match:
      # match(c("c", "a", "b"), c("c","b", "a")) # order for making 2 into 1!
      # c("c", "b", "a", "d")[match(c("c", "d", "b", "a"), c("c","b","a", "d"))] # WORKS
      # c("c", "d", "b", "a")[match(c("c", "d", "b", "a"), c("c","b","a", "d"))] # FAIL
      order <- match(order, labels(x))
   }
   
   number_of_leaves <- nleaves(x)   
   weights <- seq_len(number_of_leaves)
   weights_for_order <- numeric(number_of_leaves)
   weights_for_order[order.dendrogram(x)[order]] <- weights
   reorder(x, weights_for_order, mean,...)
}


#' @S3method rotate hclust
rotate.hclust <- function(x, order,...)
{   
   x_dend <- as.dendrogram(x)
   x_dend_rotated <- rotate(x_dend, order,...)
   x_rotated <- as_hclust_fixed(x_dend_rotated, x)
   
   return(x_rotated)
}


#' @S3method rotate phylo
rotate.phylo <- function(x, ...) ape:::rotate(phy=x, ...)


#' @S3method sort dendrogram
sort.dendrogram <- function(x, decreasing = FALSE,...) rotate(x, order(labels(x),decreasing =decreasing ,...))

#' @S3method sort hclust
sort.hclust <- function(x, decreasing = FALSE,...) rotate(x, order(labels(x),decreasing =decreasing ,...))



# flip <- function(x, ...) {
#    rev_order <- rev(seq_len(nleaves(x)))
#    rotate(x, rev_order)
# }

#' @export
rev.hclust <- function(x, ...) {
   rev_order <- rev(seq_len(nleaves(x)))
   rotate(x, rev_order,...)
}


# methods(rotate)
# methods(sort)
# help(flip)
# example(rotate)


###### Some debugging of "rotate" with ape vs dendextend
# require(ape)
# require(dendextend)
# "package:ape" %in% search() # TRUE
# ### to write: package_in_search ???
# tre <- rtree(25)
# detach("package:ape")
# hc <- hclust(dist(USArrests[c(1,6,13,20, 23),]), "ave")
# rotate(hc)
# loadedNamespaces()
# unloadNamespace("ape")
# search()
# unloadNamespace("dendextend"); attachNamespace("dendextend")
# some thoughts: http://www.ats.ucla.edu/stat/r/faq/referencing_objects.htm