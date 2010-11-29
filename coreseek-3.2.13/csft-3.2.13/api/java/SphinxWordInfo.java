/*
 * $Id: SphinxWordInfo.java 1172 2008-02-24 13:50:48Z shodan $
 */

package org.sphx.api;

/** Per-word statistics class. */
public class SphinxWordInfo
{
	/** Word form as returned from search daemon, stemmed or otherwise postprocessed. */
	public String	word;

	/** Total amount of matching documents in collection. */
	public long		docs;

	/** Total amount of hits (occurences) in collection. */
	public long		hits;

	/** Trivial constructor. */
	public SphinxWordInfo ( String word, long docs, long hits )
	{
		this.word = word;
		this.docs = docs;
		this.hits = hits;
	}
}

/*
 * $Id: SphinxWordInfo.java 1172 2008-02-24 13:50:48Z shodan $
 */
