//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.0.5-b02-fcs 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2013.06.03 at 03:51:49 PM EDT 
//


package edu.umd.cs.guitar.model.data;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="EventStateSet" type="{}EventStateSetType"/>
 *         &lt;element name="TransitionSet" type="{}TransitionSetType"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "eventStateSet",
    "transitionSet"
})
@XmlRootElement(name = "EventMachine")
public class EventMachine {

    @XmlElement(name = "EventStateSet", required = true)
    protected EventStateSetType eventStateSet;
    @XmlElement(name = "TransitionSet", required = true)
    protected TransitionSetType transitionSet;

    /**
     * Gets the value of the eventStateSet property.
     * 
     * @return
     *     possible object is
     *     {@link EventStateSetType }
     *     
     */
    public EventStateSetType getEventStateSet() {
        return eventStateSet;
    }

    /**
     * Sets the value of the eventStateSet property.
     * 
     * @param value
     *     allowed object is
     *     {@link EventStateSetType }
     *     
     */
    public void setEventStateSet(EventStateSetType value) {
        this.eventStateSet = value;
    }

    /**
     * Gets the value of the transitionSet property.
     * 
     * @return
     *     possible object is
     *     {@link TransitionSetType }
     *     
     */
    public TransitionSetType getTransitionSet() {
        return transitionSet;
    }

    /**
     * Sets the value of the transitionSet property.
     * 
     * @param value
     *     allowed object is
     *     {@link TransitionSetType }
     *     
     */
    public void setTransitionSet(TransitionSetType value) {
        this.transitionSet = value;
    }

}
