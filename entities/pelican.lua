ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Base = "haloveh_base"
ENT.Type = "vehicle"

ENT.PrintName = "D77H-TCI Pelican"
ENT.Author = "Cody Evans"
--- BASE AUTHOR: Liam0102 ---
ENT.Category = "Halo Vehicles: UNSC"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/helios/pelican/pelican_landed.mdl"
ENT.Vehicle = "pelican"
ENT.StartHealth = 2000;
ENT.Allegiance = "UNSC";

ENT.WingsModel = "models/helios/pelican/pelican.mdl"
ENT.ClosedModel = "models/helios/pelican/pelican_open.mdl"

list.Set("HaloVehicles", ENT.PrintName, ENT);

if SERVER then

ENT.FireSound = Sound("weapons/gatling_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),Switch=CurTime(),};

AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("pelican");
	e:SetPos(tr.HitPos + Vector(0,0,-5));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw+0,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()

	self:SetNWInt("Health",self.StartHealth);
	
	self.WeaponLocations = {
        TopRight = self:GetPos()+self:GetForward()*607.5+self:GetUp()*6+self:GetRight()*2,
        BottomRight = self:GetPos()+self:GetForward()*607.5+self:GetUp()*6+self:GetRight()*-2,
        TopLeft = self:GetPos()+self:GetForward()*607.5+self:GetUp()*6+self:GetRight()*2,
        TopRight = self:GetPos()+self:GetForward()*607.5+self:GetUp()*6+self:GetRight()*-2, 
	}
	self.WeaponsTable = {};
	self.BoostSpeed = 2000;
	self.ForwardSpeed = 2000;
	self.UpSpeed = 500;
	self.AccelSpeed = 10;
	self.CanStandby = false;
	self.CanBack = true;
	self.CanRoll = false;
	self.CanStrafe = true;
	self.Cooldown = 2;
	self.CanShoot = true;
	self.Bullet = CreateBulletStructure(50,"unsc");
	self.FireDelay = 0.1;
	self.NextBlast = 1;
	self.DontOverheat = true;
	self.AlternateFire = true;
	self.FireGroup = {"TopRight","TopLeft","BottomRight","BottomLeft"}
	self.HasWings = true;
    self.CanEject = false;
	
	self.ExitModifier = {x=0,y=170,z=70};
	--testexit-- self.ExitModifier = {x=20.5,y=345,z=70};
	self.PilotOffset = {x=0,y=444,z=86};

    self.PilotVisible = true;
    self.PilotPosition = {x=0,y=444,z=87}
	self.SeatPos = {
            
		{self:GetPos()+self:GetForward()*207+self:GetUp()*84+self:GetRight()*60,self:GetAngles()+Angle(0,90,-10)},
		{self:GetPos()+self:GetForward()*176+self:GetUp()*84+self:GetRight()*60,self:GetAngles()+Angle(0,90,-10)},
		{self:GetPos()+self:GetForward()*145.5+self:GetUp()*84+self:GetRight()*60,self:GetAngles()+Angle(0,90,-10)},
		{self:GetPos()+self:GetForward()*114.5+self:GetUp()*84+self:GetRight()*60,self:GetAngles()+Angle(0,90,-10)},
		{self:GetPos()+self:GetForward()*83.5+self:GetUp()*84+self:GetRight()*60,self:GetAngles()+Angle(0,90,-10)},
            
		{self:GetPos()+self:GetForward()*207+self:GetUp()*84+self:GetRight()*-60,self:GetAngles()+Angle(0,-90,-10)},
		{self:GetPos()+self:GetForward()*176+self:GetUp()*84+self:GetRight()*-60,self:GetAngles()+Angle(0,-90,-10)},
		{self:GetPos()+self:GetForward()*145.5+self:GetUp()*84+self:GetRight()*-60,self:GetAngles()+Angle(0,-90,-10)},
		{self:GetPos()+self:GetForward()*114.5+self:GetUp()*84+self:GetRight()*-60,self:GetAngles()+Angle(0,-90,-10)},
		{self:GetPos()+self:GetForward()*83.5+self:GetUp()*84+self:GetRight()*-60,self:GetAngles()+Angle(0,-90,-10)},
	}
	self:SpawnSeats();
	self.HasLookaround = true;
	self.BaseClass.Initialize(self);
end

function ENT:SpawnSeats()
	self.Seats = {};
	for k,v in pairs(self.SeatPos) do
		local e = ents.Create("prop_vehicle_prisoner_pod");
		e:SetPos(v[1]);
		e:SetAngles(v[2]+Angle(0,-90,0));
		e:SetParent(self);		
		e:SetModel("models/nova/airboat_seat.mdl");
		e:SetRenderMode(RENDERMODE_TRANSALPHA);
		e:SetColor(Color(255,255,255,0));	
		e:Spawn();
		e:Activate();
		e:SetUseType(USE_OFF);
		e:GetPhysicsObject():EnableMotion(false);
		e:GetPhysicsObject():EnableCollisions(false);
		e.IsPelicanSeat = true;
		e.Pelican = self;
		self.Seats[k] = e;
	end

end
    
function ENT:Enter(p)
    if(!IsValid(self.Pilot)) then
        self:SetModel(self.ClosedModel);
    end
    self.BaseClass.Enter(self,p);
end
    
function ENT:Exit(kill)
    local p = self.Pilot;
    if(self.Land or self.TakeOff) then
        self:SetModel(self.EntModel);
    end
	self.BaseClass.Exit(self,kill);
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

hook.Add("PlayerEnteredVehicle","PelicanSeatEnter", function(p,v)
	if(IsValid(v) and IsValid(p)) then
		if(v.IsPelicanSeat) then
			p:SetNetworkedEntity("Pelican",v:GetParent());
            p:SetNetworkedEntity("PelicanSeat",v);
		end
	end
end);

hook.Add("PlayerLeaveVehicle", "PelicanSeatExit", function(p,v)
	if(IsValid(p) and IsValid(v)) then
		if(v.IsPelicanSeat) then
            if(v.PelicanFrontSeat) then
                local self = v:GetParent();
                p:SetPos(self:GetPos()+self:GetForward()*270+self:GetUp()*170);
            else
                p:SetPos(v:GetPos()+v:GetForward()*37+v:GetUp()*5+v:GetRight()*0);
            end
			p:SetNetworkedEntity("Pelican",NULL);
            p:SetNetworkedEntity("PelicanSeat",NULL);
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
            local min = self:GetPos()+self:GetForward()*400+self:GetUp()*60+self:GetRight()*-50;
            local max = self:GetPos()+self:GetForward()*450+self:GetUp()*150+self:GetRight()*50
            for k,v in pairs(ents.FindInBox(min,max)) do
               if(v == p) then
                    self:Enter(p);
                    break;
                end
            end	
		else
			self:Passenger(p);
		end
	else
		if(p != self.Pilot) then
			self:Passenger(p);
		end
	end
end

function ENT:Think()
 
    if(self.Inflight) then
        if(IsValid(self.Pilot)) then
            if(IsValid(self.Pilot)) then 
                if(self.Pilot:KeyDown(IN_ATTACK2) and self.NextUse.FireBlast < CurTime()) then
                    self.BlastPositions = {
                        self:GetPos() + self:GetForward() * 300 + self:GetRight() * 220 + self:GetUp() * 150, //1
						self:GetPos() + self:GetForward() * 300 + self:GetRight() * -220 + self:GetUp() * 150, //1
						self:GetPos() + self:GetForward() * 300 + self:GetRight() * 220 + self:GetUp() * 150, //2
						self:GetPos() + self:GetForward() * 300 + self:GetRight() * -220 + self:GetUp() * 150, //2
                    }
                    self:FirePelicanBlast(self.BlastPositions[self.NextBlast], false, 250, 300, true, 8, Sound("weapons/hornet_missle.wav"));
					self.NextBlast = self.NextBlast + 1;
					if(self.NextBlast == 5) then
						self.NextUse.FireBlast = CurTime()+20;
						self:SetNWBool("OutOfMissiles",true);
						self:SetNWInt("FireBlast",self.NextUse.FireBlast)
						self.NextBlast = 1;
					end
					
					
                end
			end
		end
		
		if(self.NextUse.FireBlast < CurTime()) then
			self:SetNWBool("OutOfMissiles",false);
		end
        self:SetNWInt("Overheat",self.Overheat);
        self:SetNWBool("Overheated",self.Overheated);
    end
    self.BaseClass.Think(self);
end

function ENT:FirePelicanBlast(pos,gravity,vel,dmg,white,size,snd)
	local e = ents.Create("missle_blast");
	
	e.Damage = dmg or 600;
	e.IsWhite = white or false;
	e.StartSize = size or 20;
	e.EndSize = size*0.75 or 15;
	
	local sound = snd or Sound("weapons/hornet_missle.wav");
	
	e:SetPos(pos);
	e:Spawn();
	e:Activate();
	e:Prepare(self,sound,gravity,vel);
	e:SetColor(Color(255,255,255,1));
	
end

end

if CLIENT then
	
	ENT.CanFPV = true;
	ENT.Sounds={
		Engine=Sound("vehicles/pelican_fly.wav"),
    }
	
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
			heatwv:SetDieTime(0.01);
			heatwv:SetStartAlpha(255);
			heatwv:SetEndAlpha(255);
			heatwv:SetStartSize(30);
			heatwv:SetEndSize(25);
			heatwv:SetColor(255,255,255);
			heatwv:SetRoll(roll);
			
			local blue = self.FXEmitter:Add("sprites/bluecore",v+FWD*25)
			blue:SetVelocity(normal)
			blue:SetDieTime(0.05)
			blue:SetStartAlpha(95)
			blue:SetEndAlpha(20)
			blue:SetStartSize(20)
			blue:SetEndSize(1)
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
					self:GetPos()+self:GetForward()*-500+self:GetUp()*280+self:GetRight()*85,
					self:GetPos()+self:GetForward()*-500+self:GetUp()*280+self:GetRight()*-130,
					
					self:GetPos()+self:GetForward()*35+self:GetUp()*212+self:GetRight()*-215,
					self:GetPos()+self:GetForward()*35+self:GetUp()*212+self:GetRight()*165,
				}
				self:Effects();
			end
		end
		self.BaseClass.Think(self)
	end
	
	local View = {}
	local lastpos, lastang;
	local function PelicanCalcView()
		
		local p = LocalPlayer();
		local self = p:GetNWEntity("Pelican",NULL)
        local flying = p:GetNWBool("FlyingPelican");
		local pos,face;
        if(flying) then
            if(IsValid(self)) then
                local fpvPos = self:GetPos()+self:GetRight()*0+self:GetForward()*443+self:GetUp()*106;
                if(LightSpeed == 2 and !self:GetFPV()) then
                    pos = lastpos;
                    face = lastang;

                    View.origin = pos;
                    View.angles = face;
                else
                    pos = self:GetPos()+self:GetUp()*650+LocalPlayer():GetAimVector():GetNormal()*-1300;			
                    face = ((self:GetPos() + Vector(0,0,100))- pos):Angle()
                    View =  HALOVehicleView(self,1300,450,fpvPos,true);
                end

                lastpos = pos;
                lastang = face;

                return View;
            end
        else
            local v = p:GetNWEntity("PelicanSeat",NULL);
            if(IsValid(v)) then
                if(v:GetThirdPersonMode()) then
                    return HALOVehicleView(self,1300,450,fpvPos);
                end
            end
        end
	end
	hook.Add("CalcView", "PelicanView", PelicanCalcView)
	
	function PelicanReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingPelican");
		local self = p:GetNWEntity("Pelican");
		if(Flying and IsValid(self)) then
			HALO_HUD_DrawHull(2000);
			HALO_WeaponReticles(self);
			HALO_HUD_Compass(self,x,y);
			HALO_HUD_DrawSpeedometer();
			HALO_BlastIcon(self,20);
		end
	end
	hook.Add("HUDPaint", "PelicanReticle", PelicanReticle)

    
	hook.Add("ScoreboardShow","PelicanScoreDisable", function()
		local p = LocalPlayer();	
		local Flying = p:GetNWBool("FlyingPelican");
		if(Flying) then
			return false;
		end
	end)
end