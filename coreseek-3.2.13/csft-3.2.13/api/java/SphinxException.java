/*
 * $Id: SphinxException.java 1172 2008-02-24 13:50:48Z shodan $
 */

package org.sphx.api;

/** Exception thrown on attempts to pass invalid arguments to Sphinx API methods. */
public class SphinxException extends Exception
{
	/** Trivial constructor. */
	public SphinxException()
	{
	}

	/** Constructor from error message string. */
	public SphinxException ( String message )
	{
		super ( message );
	}
}

/*
 * $Id: SphinxException.java 1172 2008-02-24 13:50:48Z shodan $
 */
