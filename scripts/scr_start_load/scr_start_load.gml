function scr_start_load(fleet, load_from_star, escort_load) {
    // fleet: the fleet object
    // load_from_star: star object
    // escort_load: 1 for including escorts, 2 for no escorts

    // this distributes the marines and vehicles to the correct ships if the chapter is fleet-based or a home-based chapter
	
	
	// i feel like there definatly is or should be a generic function for this????
	var _vehicles = ["Rhino", "Predator", "Land Speeder", "Land Raider", "Whirlwind"]
	function load_vehicles(_companies, _equip ,_ship, size){
			obj_ini.veh_wid[_companies, _equip] = 0;
			obj_ini.veh_lid[_companies, _equip] = _ship;
			obj_ini.veh_loc[_companies, _equip] = obj_ini.ship_location[_ship];	
			obj_ini.ship_carrying[_ship] += size;
	}
    var splinter, company_size, ship, ship_size, companies_loaded;
    splinter = 0;
    company_size = 0;
    ship = 1;
    //ship_size = obj_ini.ship_size[ship];
    companies_loaded = 1;
	var ship_return = 1;
	var ship_has_space =true;

	//thread for now defunct splinter fleets new algorithm just sorts marines into ships and ship location determines splinter status
    if (string_count("Splinter", obj_ini.strin2) > 0) then splinter = 1;
	
		//loop through companies. try and load whole company onto single ship else spread company across largest ships with remaining space
	for (var _comp =0; _comp<10;_comp++;){
		var _company_size = 0;
		var company_loader =[];//array of companies marines
		var company_vehicle = [];//array of companies vehicles
		var  ship_fit = true;
		for (var _unit =1; _unit<(array_length(obj_ini.role[_comp])-1); _unit++){
				var _marine = obj_ini.TTRPG[_comp, _unit];
				// check if marine exists
				if (_marine.name() != "") {
					show_debug_message("{0},{1},{2},{3}", _marine.company,_marine.marine_number,_comp, _unit )
					//calculate marine space
					var marine_size =  _marine.get_unit_size();
					_company_size += marine_size;
					array_push(company_loader, _marine)
				}
			 //fetch company vehicles
			 if (_unit <array_length(obj_ini.veh_role[_comp])){
				 if array_contains(_vehicles,obj_ini.veh_role[_comp, _unit]){
						 var _vehic_size = scr_unit_size(false, obj_ini.veh_role[_comp, _unit], false, false);
						 _company_size += _vehic_size;
					 array_push(company_vehicle,  [_comp, _unit, _vehic_size])
				 }
			 }
			
		}
					//if company won't fit onto ship
		if ((obj_ini.ship_carrying[ship] + _company_size) > obj_ini.ship_capacity[ship]){
			ship_fit = false;
		}		
		//if entire company won't fit on ship test to see if there is any ship in the fleet the company will fit on;
		 if (ship_fit == false){
			 for (var ship_loop =  ship; ship_loop< array_length(obj_ini.ship_carrying);ship_loop++;){
				  if ((obj_ini.ship_carrying[ship_loop] + _company_size) <= obj_ini.ship_capacity[ship_loop]){
					  //load marines
					  for (var m = 0; m <array_length(company_loader);m++;){
						   company_loader[m].load_marine(ship_loop);
					  }
					  //load vehicles
					  for (var m = 0; m <array_length(company_vehicle);m++;){
						   load_vehicles(company_vehicle[m][0], company_vehicle[m][1], ship_loop,  company_vehicle[m][2]);
					  }
					  ship_fit = true;
					  break;

				  }
			 }
			 // if there are no ships that will hold the entire company loop all ships and jam pac the fuckers in in
			 if (ship_fit == false){
				 for (var ship_loop = ship; ship_loop<array_length(obj_ini.ship_carrying); ship_loop++;){
				 if (obj_ini.ship_carrying[ship_loop] < obj_ini.ship_capacity[ship_loop]){
					 ship_has_space = true;	
					 // new arrays that will contain troops that didn't get loaded
					 var comp_edit =[];
					 var veh_edit = [];
					 
					 for (var m = 0; m <array_length(company_loader);m++;){
						 if ((obj_ini.ship_carrying[ship_loop] + company_loader[m].size) <= obj_ini.ship_capacity[ship_loop]){
							company_loader[m].load_marine(ship_loop);
						 } else {array_push(comp_edit, company_loader[m])}
						 if (obj_ini.ship_carrying[ship_loop] = obj_ini.ship_capacity[ship_loop]){
							 ship_has_space = false;
							 break;
						 }
					  }
					  for (var m = 0; m <array_length(company_vehicle);m++;){
						  if ((obj_ini.ship_carrying[ship_loop] + company_vehicle[m][2]) <= obj_ini.ship_capacity[ship_loop]){
							load_vehicles(company_vehicle[m][0], company_vehicle[m][1], ship_loop, company_vehicle[m][2]);
						  } else {array_push( veh_edit, company_vehicle[m])}
						  if (obj_ini.ship_carrying[ship_loop] = obj_ini.ship_capacity[ship_loop]){
							   ship_has_space = false;
							   break;
						  }
					  }					  
					   company_loader= comp_edit;
					   company_vehicle = veh_edit;
					}
				 }
			 }
		 } else{
			 for (var m = 0; m <array_length(company_loader);m++;){
				company_loader[m].load_marine(ship);
			}
			for (var m = 0; m <array_length(company_vehicle);m++;){
				load_vehicles(company_vehicle[m][0], company_vehicle[m][1], ship,  company_vehicle[m][2]);
			}		 
		 }
	}
	}