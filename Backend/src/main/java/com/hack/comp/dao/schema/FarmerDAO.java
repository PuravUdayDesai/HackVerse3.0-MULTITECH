package com.hack.comp.dao.schema;

import java.sql.SQLException;
import java.util.List;

import com.hack.comp.model.farmer.FarmerInsert;
import com.hack.comp.model.farmer.FarmerLoginModel;
import com.hack.comp.model.farmer.FarmerPurchaseHistoryModel;

public interface FarmerDAO 
{
	 public FarmerLoginModel					validateFarmer(String username,String password)	throws SQLException,ClassNotFoundException;
	 public Boolean 							addFarmer(FarmerInsert fi)						throws SQLException,ClassNotFoundException;
	 public List<FarmerPurchaseHistoryModel> 	selectFarmerPurchaseHistory(Long farmerId)		throws SQLException,ClassNotFoundException;
}
