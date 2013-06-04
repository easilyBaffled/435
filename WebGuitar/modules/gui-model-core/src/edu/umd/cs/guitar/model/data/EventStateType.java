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
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for EventStateType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="EventStateType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="EventStateId" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="Initial" type="{http://www.w3.org/2001/XMLSchema}boolean"/>
 *         &lt;element name="EventSet" type="{}EventSetType"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "EventStateType", propOrder = {
    "eventStateId",
    "initial",
    "eventSet"
})
public class EventStateType {

    @XmlElement(name = "EventStateId", required = true)
    protected String eventStateId;
    @XmlElement(name = "Initial")
    protected boolean initial;
    @XmlElement(name = "EventSet", required = true)
    protected EventSetType eventSet;

    /**
     * Gets the value of the eventStateId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEventStateId() {
        return eventStateId;
    }

    /**
     * Sets the value of the eventStateId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEventStateId(String value) {
        this.eventStateId = value;
    }

    /**
     * Gets the value of the initial property.
     * 
     */
    public boolean isInitial() {
        return initial;
    }

    /**
     * Sets the value of the initial property.
     * 
     */
    public void setInitial(boolean value) {
        this.initial = value;
    }

    /**
     * Gets the value of the eventSet property.
     * 
     * @return
     *     possible object is
     *     {@link EventSetType }
     *     
     */
    public EventSetType getEventSet() {
        return eventSet;
    }

    /**
     * Sets the value of the eventSet property.
     * 
     * @param value
     *     allowed object is
     *     {@link EventSetType }
     *     
     */
    public void setEventSet(EventSetType value) {
        this.eventSet = value;
    }

}
