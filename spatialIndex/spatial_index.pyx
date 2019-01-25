from cpython cimport array
import array


cdef extern from "sptQuery.h":

    cdef struct sptConstraints:
         int status
         char *errorMsg
         char *indexConstraint
         char *geomConstraint

    cdef sptConstraints sptConeSearch(int indexMode, int level, double ra, double dec, double radius)

    cdef sptConstraints sptPolygonSearch(int indexMode, int level, int npoly, double *ra, double *decs)


class SpatialIndex:

    """
    SpatialIndex class

    This spatial indexing class provides functions for converting astronomical
    spatial constraints (cone or convex polygon on the sky) into constraints
    appropriate for inclusion in SQL DBMS searches.  It is assumed that the
    DBMS tables have been augmented with a spatial index (integer) column at
    some HTM or HEALPix level and (x,y,z) three-vector coordinates for each
    record.
    """

    def __init__(self):

       self.HTM = 0
       self.HPX = 1


    def cone_search(self, ra, dec, radius, mode=0, level=7):

        """
        cone_search() converts a cone on the sky (RA, Dec, radius) into
        a pair of SQL fragments that can be added to an SQL statement.
        
        Parameters
        ----------
        ra : double, required
            Right Ascension (decimal degrees J2000) of center of search cone.
        dec : double, required
            Declination (decimal degrees J2000) of center of search cone.
        radius : double, required
            Radius (decimal degrees) of search cone.
        mode : integer, optional, default 0 (SpatialIndex.HTM)
            Indexing mode (SpatialIndex.HTM or SpatialIndex.HPX)
        level : double, optional, default 7
            Depth of the indexing.
            
        Returns
        -------
        The return is a dictionary with integer status and two strings:  
        index_constraint (specifying the spatial index cells covered) and 
        geom_constraint (an exact filter for the sky region).  If the return 
        status is 1, an error_message is returned instead.
        """

        ret_struct = sptConeSearch(mode, level, ra, dec, radius)

        retval = {}

        retval['status'] = ret_struct.status

        if retval['status'] == 1:
            retval['error_message'] = ret_struct.errorMsg.decode('utf-8')

        else:
            retval['index_constraint'] = ret_struct.indexConstraint.decode('utf-8')
            retval['geom_constraint'] = ret_struct.geomConstraint.decode('utf-8')

        return retval


    def polygon_search(self, npoly, ra, dec,  mode=0, level=7):

        """
        polygon_search() converts a convex polygon on the sky into a pair 
        of SQL fragments that can be added to an SQL statement.
        
        Parameters
        ----------
        npoly : int, required
            Number of polygon points (greater than or equal to 3)
        ra : double list, required
            Right Ascensions (decimal degrees J2000) of the polygon points.
        dec : double, required
            Declinations (decimal degrees J2000) of the polygon points.
        mode : integer, optional, default 0 (SpatialIndex.HTM)
            Indexing mode (SpatialIndex.HTM or SpatialIndex.HPX)
        level : double, optional, default 7
            Depth of the indexing.
            
        Returns
        -------
        The return is a dictionary with integer status and two strings:  
        index_constraint (specifying the spatial index cells covered) and 
        geom_constraint (an exact filter for the sky region).  If the return 
        status is 1, an error_message is returned instead.
        """


        cdef array.array ra_array = array.array('d', ra)
        cdef array.array dec_array = array.array('d', dec)

        ret_struct = sptPolygonSearch(mode, level, npoly, ra_array.data.as_doubles, dec_array.data.as_doubles)

        retval = {}

        retval['status'] = ret_struct.status

        if retval['status'] == 1:
            retval['error_message'] = ret_struct.errorMsg.decode('utf-8')

        else:
            retval['index_constraint'] = ret_struct.indexConstraint.decode('utf-8')
            retval['geom_constraint'] = ret_struct.geomConstraint.decode('utf-8')

        return retval

