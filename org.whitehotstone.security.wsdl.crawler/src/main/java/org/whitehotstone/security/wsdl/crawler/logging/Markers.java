package org.whitehotstone.security.wsdl.crawler.logging;

import org.slf4j.Marker;
import org.slf4j.MarkerFactory;

public enum Markers {
    MAIN("MAIN"),
    MAIN_EXEC("MAIN_EXEC"),
	FILE_VISITOR("FILE VISITOR"),
	WSDL_TRAVERSER("WSDL_TRAVERSER"),
	XML_SCHEMA_TRAVERSER("XML_SCHEMA_TRAVERSER"),
	GENERATOR("GENERATOR");

	private Marker marker;

	private Markers(String name) {
		this.marker = MarkerFactory.getMarker(name);
	}

	public Marker getInstance() {
		return marker;
	}
}
