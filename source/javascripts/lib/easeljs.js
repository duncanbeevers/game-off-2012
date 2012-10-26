// Manifesto for easeljs dependency-order issues

//= require lib/easeljs/utils/UID
//= require lib/easeljs/geom/Matrix2D

//= require lib/easeljs/display/DisplayObject
//= require lib/easeljs/display/Container
//= require lib/easeljs/display/Shape
//= require lib/easeljs/display/Graphics
//= require lib/easeljs/display/Stage

//= require lib/easeljs/filters/Filter

// TODO: Lazy-load as much as we can
//= require_tree ./easeljs