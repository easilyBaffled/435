//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, vJAXB 2.1.10 in JDK 6 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2012.02.26 at 12:45:39 AM EST 
//


package edu.umd.cs.guitar.gen;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for ContentsType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="ContentsType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;choice maxOccurs="unbounded">
 *           &lt;element name="Widget" type="{}ComponentType"/>
 *           &lt;element name="Container" type="{}ContainerType"/>
 *         &lt;/choice>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ContentsType", propOrder = {
    "widgetOrContainer"
})
public class ContentsType {

    @XmlElements({
        @XmlElement(name = "Container", type = ContainerType.class),
        @XmlElement(name = "Widget")
    })
    protected List<ComponentType> widgetOrContainer;

    /**
     * Gets the value of the widgetOrContainer property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the widgetOrContainer property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getWidgetOrContainer().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link ContainerType }
     * {@link ComponentType }
     * 
     * 
     */
    public List<ComponentType> getWidgetOrContainer() {
        if (widgetOrContainer == null) {
            widgetOrContainer = new ArrayList<ComponentType>();
        }
        return this.widgetOrContainer;
    }

}
