package com.hack.comp.controller;

import java.util.List;

import javax.validation.Valid;
import javax.validation.constraints.NotNull;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.hack.comp.bl.FarmerBusinessLogic;
import com.hack.comp.model.farmer.FarmerInsert;
import com.hack.comp.model.farmer.FarmerLoginModel;
import com.hack.comp.model.farmer.FarmerPurchaseHistoryModel;


@RestController
@RequestMapping("/farmer")
@CrossOrigin(origins = "*")
/*
 * Farmer is the person who gets benefit of less price fertilizer, biogas and bioenzyme
 */
public class FarmerController
{
	@Autowired
	FarmerBusinessLogic fbl;
	
    @GetMapping
    public ResponseEntity<FarmerLoginModel> validateFarmer(@RequestParam(name = "username") String username, @RequestParam(name = "password") String password) 
    {
    	return fbl.validateFarmer(username, password);
    }

    // REGISTER
    @PostMapping(produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
    public ResponseEntity<Void> addFarmer(@Valid @RequestBody FarmerInsert fi)
    {
    	return fbl.addFarmer(fi);
    }
    
    @GetMapping(path="/purchase/{farmerId}", produces = { MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE })
	public ResponseEntity<List<FarmerPurchaseHistoryModel>> selectFarmerPurchaseHistory(@PathVariable @NotNull Long farmerId)
	{
		return fbl.selectFarmerPurchaseHistory(farmerId);
	}

}
