/*
 The MIT License

 Copyright (c) 2011 Filipe Prata de Lima
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */
package com.pixeplastik.parsley.utils
{
import flash.events.EventDispatcher;

import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.xml.mapper.XmlObjectMappings;

   /**
    * Map XML data to a given Value Object, using Parsley's SpiceLib XML Mapper
	* 
	* @author filipelima.com
    *
    * @see http://www.spicefactory.org/parsley/docs/3.0/manual/xmlmapper.php
    * @see http://www.spicefactory.org/parsley/docs/2.4/api/parsley-flex/org/spicefactory/lib/xml/mapper/package-detail.html
    */
public class XMLToObjectMapper extends EventDispatcher
{
    public function XMLToObjectMapper()
    {
    }

    /**
     * @param xml Raw xml data
     * @param vo Value Object class
     * @param voChildren Value Object children classes
     */
    public static function mapToObject(xml:XML, rootElement:*, voChildren:Array = null):Object
    {
        var mappings:XmlObjectMappings = XmlObjectMappings.forUnqualifiedElements().withRootElement(rootElement);

        // add child mapper
        if(voChildren)
        {
            var childVO:*;
            for each(childVO in voChildren)
            {
                // make child mapping
                var mapping:XmlObjectMappings = XmlObjectMappings
                        .forUnqualifiedElements()
                        .withoutRootElement()
                        .mappedClasses(childVO);

                // merge to main
                mappings.mergedMappings(mapping);
            }
        }

        var mapper:XmlObjectMapper = mappings.build();

        try
        {
            var obj:* = mapper.mapToObject(xml);
            return obj;
        }
        catch(e:Error)
        {
            throw("[Unable to map XML to Object]: " + e.message);
        }

        return null;
    }
}
}

