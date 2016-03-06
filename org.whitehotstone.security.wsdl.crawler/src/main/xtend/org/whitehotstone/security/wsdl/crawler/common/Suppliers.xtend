package org.whitehotstone.security.wsdl.crawler.common

import com.google.common.base.Supplier
import java.util.List

class Suppliers {
    static class ListSupplier<V> implements Supplier<List<V>> {
        override get() {
            newArrayList()
        }
    }
}
