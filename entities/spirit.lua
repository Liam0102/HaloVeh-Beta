ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Base = "haloveh_base"
ENT.Type = "vehicle"

ENT.PrintName = "T-25 Spirit"
ENT.Author = "Cody Evans"
--- BASE AUTHOR: Liam0102 ---
ENT.Category = "Halo Vehicles: Covenant"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/helios/spirit/spirit_open.mdl"
ENT.Vehicle = "spirit"
ENT.StartHealth = 2000;
ENT.Allegiance = "Covenant";

ENT.WingsModel = "models/helios/spirit/spirit.mdl"
ENT.ClosedModel = "models/helios/spirit/spirit_open.mdl"

list.Set("HaloVehicles", ENT.PrintName, ENT);

if SERVER then

ENT.FireSound = Sound("weapons/banshee_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),};

AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("spirit");
	e:SetPos(tr.HitPos + Vector(0,0,0));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()


	self:SetNWInt("Health",self.StartHealth);
	
	self.WeaponLocations = {
		Right = self:GetPos()+self:GetForward()*-200+self:GetUp()*50+self:GetRight()*0,
		Left = self:GetPos()+self:GetForward()*-200+self:GetUp()*50+self:GetRight()*0,
	}
	self.WeaponsTable = {};
	self.BoostSpeed = 2000;
	self.ForwardSpeed = 2000;
	self.UpSpeed = 500;
	self.AccelSpeed = 9;
	self.CanStandby = true;
	self.CanBack = false;
    self.CanRoll = false;
    self.CanStrafe = true;
	self.CanShoot = true;
	self.DontOverheat = true;
	self.AlternateFire = true;
	self.FireGroup = {"Right","Left"}
	self.HasWings = true;
	self.Cooldown = 2;
	self.LandOffset = Vector(0,0,1);
	
	self.Bullet = CreateBulletStructure(40,"plasma");
	self.FireDelay = 0.15;
	
	self.SeatPos = {
	
		{self:GetPos()+self:GetUp()*163+self:GetRight()*-185+self:GetForward()*-97, self:GetAngles()+Angle(0,0,0)},
		{self:GetPos()+self:GetUp()*163+self:GetRight()*185+self:GetForward()*-97, self:GetAngles()+Angle(0,180,0)},
		
		{self:GetPos()+self:GetUp()*163+self:GetRight()*-185+self:GetForward()*-26, self:GetAngles()+Angle(0,0,0)},
		{self:GetPos()+self:GetUp()*163+self:GetRight()*185+self:GetForward()*-26, self:GetAngles()+Angle(0,180,0)},
	
		{self:GetPos()+self:GetUp()*163+self:GetRight()*-185+self:GetForward()*43, self:GetAngles()+Angle(0,0,0)},
		{self:GetPos()+self:GetUp()*163+self:GetRight()*185+self:GetForward()*43, self:GetAngles()+Angle(0,180,0)},
		
		{self:GetPos()+self:GetUp()*163+self:GetRight()*-185+self:GetForward()*111.5, self:GetAngles()+Angle(0,0,0)},
		{self:GetPos()+self:GetUp()*163+self:GetRight()*185+self:GetForward()*111.5, self:GetAngles()+Angle(0,180,0)},
		
		{self:GetPos()+self:GetUp()*163+self:GetRight()*-185+self:GetForward()*174.8, self:GetAngles()+Angle(0,0,0)},
		{self:GetPos()+self:GetUp()*163+self:GetRight()*185+self:GetForward()*174.8, self:GetAngles()+Angle(0,180,0)},
		
		{self:GetPos()+self:GetUp()*163+self:GetRight()*-185+self:GetForward()*244.5, self:GetAngles()+Angle(0,0,0)},
		{self:GetPos()+self:GetUp()*163+self:GetRight()*185+self:GetForward()*244.5, self:GetAngles()+Angle(0,180,0)},
		
		{self:GetPos()+self:GetUp()*163+self:GetRight()*-185+self:GetForward()*314.5, self:GetAngles()+Angle(0,0,0)},
		{self:GetPos()+self:GetUp()*163+self:GetRight()*185+self:GetForward()*314.5, self:GetAngles()+Angle(0,180,0)},
		
		{self:GetPos()+self:GetUp()*163+self:GetRight()*-185+self:GetForward()*384.5, self:GetAngles()+Angle(0,0,0)},
		{self:GetPos()+self:GetUp()*163+self:GetRight()*185+self:GetForward()*384.5, self:GetAngles()+Angle(0,180,0)},

		
	};
	
	self:SpawnSeats();
	self.ExitModifier = {x=0,y=-20,z=40};

	self.PilotVisible = true;
	self.PilotPosition = {x=0,y=-220,z=223};

	self.HasLookaround = true;
	self.BaseClass.Initialize(self);
end


function ENT:SpawnSeats()
	self.Seats = {};
	for k,v in pairs(self.SeatPos) do
		local e = ents.Create("prop_vehicle_prisoner_pod");
		e:SetPos(v[1]);
		e:SetAngles(v[2]);
		e:SetParent(self);		
		e:SetModel("models/nova/airboat_seat.mdl");
		e:SetRenderMode(RENDERMODE_TRANSALPHA);
		e:SetColor(Color(255,255,255,0));	
		e:Spawn();
		e:Activate();
		e:SetVehicleClass("idle_chair");
		e:SetUseType(USE_OFF);
		e:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		//e:GetPhysicsObject():EnableCollisions(false);
		e.IsSpiritSeat = true;
		e.Spirit = self;
		
		if(k % 2 > 0) then
			e.RightSide = true;
		else
			e.LeftSide = true;
		end
		
		self.Seats[k] = e;
	end

end

hook.Add("PlayerEnteredVehicle","SpiritSeatEnter", function(p,v)
	if(IsValid(v) and IsValid(p)) then
		if(v.IsSpiritSeat) then
			p:SetNetworkedEntity("SpiritSeat",v);
			p:SetNetworkedEntity("Spirit",v:GetParent());
			p:SetNetworkedBool("SpiritPassenger",true);
		end
	end
end);

hook.Add("PlayerLeaveVehicle", "SpiritSeatExit", function(p,v)
	if(IsValid(p) and IsValid(v)) then
		if(v.IsSpiritSeat) then
            if(v.SpiritFrontSeat) then
                local self = v:GetParent();
                p:SetPos(self:GetPos()+self:GetForward()*270+self:GetUp()*170);
            else
                p:SetPos(v:GetPos()+v:GetForward()*70+v:GetUp()*-20+v:GetRight()*0);
            end
			p:SetNetworkedEntity("Spirit",NULL);
            p:SetNetworkedEntity("SpiritSeat",NULL);
		end
	end
end);

function ENT:Passenger(p)
	if(self.NextUse.Use > CurTime()) then return end;
	for k,v in pairs(self.Seats) do
		if(v:GetPassenger(1) == NULL) then
			p:EnterVehicle(v);
			return;
		end
	end
end
 
function ENT:Use(p)
   if(not self.Inflight) then
       if(!p:KeyDown(IN_WALK)) then
           self:Enter(p);
       else
           self:Passenger(p);
       end
   else
       if(p != self.Pilot) then
           self:Passenger(p);
       end
   end
end

function ENT:ToggleWings()
    if(!IsValid(self)) then return end;
	if(self.NextUse.Wings < CurTime()) then
		if(self.Wings) then
			self:SetModel(self.ClosedModel);
			self.Wings = false;
		else
			self.Wings = true;
			self:SetModel(self.WingsModel);
		end
		self.NextUse.Wings = CurTime() + 1;
	end
end

end

if CLIENT then

	function ENT:Draw() self:DrawModel() end
	
	ENT.EnginePos = {}
	ENT.Sounds={
		Engine=Sound("vehicles/banshee_fly.wav"),
	}
	ENT.CanFPV = false;

	hook.Add("ScoreboardShow","SpiritScoreDisable", function()
		local p = LocalPlayer();	
		local Flying = p:GetNWBool("FlyingSpirit");
		if(Flying) then
			return false;
		end
	end)
	
	function ENT:Initialize()
		self.Emitter = ParticleEmitter(self:GetPos());
		self.BaseClass.Initialize(self);
	end
	
	function ENT:Effects()
	

		local p = LocalPlayer();
		local roll = math.Rand(-45,45);
		local normal = (self.Entity:GetRight() * -1):GetNormalized();
		local FWD = self:GetRight();
		local id = self:EntIndex();
		for k,v in pairs(self.EnginePos) do

			local heatwv = self.Emitter:Add("sprites/heatwave",v+FWD*25);
			heatwv:SetVelocity(normal*2);
			heatwv:SetDieTime(0.03);
			heatwv:SetStartAlpha(255);
			heatwv:SetEndAlpha(255);
			heatwv:SetStartSize(40);
			heatwv:SetEndSize(25);
			heatwv:SetColor(255,255,255);
			heatwv:SetRoll(roll);
			
			local blue = self.FXEmitter:Add("sprites/bluecore",v+FWD*25)
			blue:SetVelocity(normal)
			blue:SetDieTime(0.07)
			blue:SetStartAlpha(155)
			blue:SetEndAlpha(20)
			blue:SetStartSize(30)
			blue:SetEndSize(5)
			blue:SetRoll(roll)
			blue:SetColor(255,255,255)

		end
	end
	
	function ENT:Think()
		
		local p = LocalPlayer();
		local Flying = self:GetNWBool("Flying".. self.Vehicle);
		local TakeOff = self:GetNWBool("TakeOff");
		local Land = self:GetNWBool("Land");
		if(Flying) then
			if(!TakeOff and !Land) then
				self.EnginePos = {
					self:GetPos()+self:GetForward()*-540+self:GetUp()*120+self:GetRight()*35,
					self:GetPos()+self:GetForward()*-540+self:GetUp()*120+self:GetRight()*-80,
					
				}
				self:Effects();
			end
		end
		self.BaseClass.Think(self)
	end
	
	hook.Add( "ShouldDrawLocalPlayer", "CGILAATDrawPlayerModel", function( p )
		local self = p:GetNWEntity("CGILAAT", NULL);
		local PassengerSeat = p:GetNWEntity("CGILAATSeat",NULL);
		if(IsValid(self)) then
			if(IsValid(PassengerSeat)) then
				if(PassengerSeat:GetThirdPersonMode()) then
					return true;
				end
			end
		end
	end);
	
	local View = {}
	local function CalcView()
		
		local p = LocalPlayer();	
		local Flying = p:GetNWBool("FlyingSpirit");
		local Sitting = p:GetNWBool("SpiritPassenger");
		local pos, face;
		local self = p:GetNWEntity("Spirit");
	
		
		if(Flying) then
			if(IsValid(self)) then
				local fpvPos = self:GetPos()+self:GetUp()*155+self:GetForward()*210;
				View = HALOVehicleView(self,1250,400,fpvPos,true);		
				return View;
			end
		elseif(Sitting) then
			local v = p:GetNWEntity("SpiritSeat");	
			if(IsValid(v)) then
				if(v:GetThirdPersonMode()) then
					View = HALOVehicleView(self,950,500,fpvPos);		
					return View;
				end
			end
		end
		
	end
	hook.Add("CalcView", "SpiritView", CalcView)

	function SpiritReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingSpirit");
		local self = p:GetNWEntity("Spirit");
		if(Flying and IsValid(self)) then
			HALO_HUD_DrawHull(2000);
			HALO_HUD_Compass(self);
			HALO_HUD_DrawSpeedometer();
			HALO_WeaponReticles(self);
		end
	end
	hook.Add("HUDPaint", "SpiritReticle", SpiritReticle)

end