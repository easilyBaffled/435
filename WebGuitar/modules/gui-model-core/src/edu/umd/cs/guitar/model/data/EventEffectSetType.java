//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.0.5-b02-fcs 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2013.06.02 at 01:39:42 PM PDT 
//


package edu.umd.cs.guitar.model.data;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for EventEffectSetType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="EventEffectSetType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="EventEffect" type="{}EventEffectType" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "EventEffectSetType", propOrder = {
    "eventEffect"
})
public class EventEffectSetType {

    @XmlElement(name = "EventEffect")
    protected List<EventEffectType> eventEffect;

    /**
     * Gets the value of the eventEffect property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the eventEffect property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getEventEffect().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link EventEffectType }
     * 
     * 
     */
    public List<EventEffectType> getEventEffect() {
        if (eventEffect == null) {
            eventEffect = new ArrayList<EventEffectType>();
        }
        return this.eventEffect;
    }

    /**
     * Sets the value of the eventEffect property.
     * 
     * @param eventEffect
     *     allowed object is
     *     {@link EventEffectType }
     *     
     */
    public void setEventEffect(List<EventEffectType> eventEffect) {
        this.eventEffect = eventEffect;
    }

}
