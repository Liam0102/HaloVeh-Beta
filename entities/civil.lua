ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Base = "haloveh_base"
ENT.Type = "vehicle"
 
ENT.PrintName = "Civilian Transport"
ENT.Author = "Cody Evans"
--- BASE AUTHOR: Liam0102 ---
ENT.Category = "Halo Vehicles: UNSC"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
 
ENT.EntModel = "models/helios/civilian_transport_ship/civilian_transport_ship.mdl"
ENT.Vehicle = "civil"
ENT.StartHealth = 2000;
ENT.Allegiance = "UNSC";

ENT.WingsModel = "models/helios/civilian_transport_ship/civilian_transport_ship.mdl"
ENT.ClosedModel = "models/helios/civilian_transport_ship/civilian_transport_ship_nogear.mdl"

list.Set("HaloVehicles", ENT.PrintName, ENT);
 
if SERVER then
 
ENT.FireSound = Sound("weapons/heavy_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),LightSpeed=CurTime(),Switch=CurTime(),};
ENT.HyperDriveSound = Sound("vehicles/hyperdrive.mp3");
 
AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
    local e = ents.Create("civil");
    e:SetPos(tr.HitPos + Vector(0,0,0));
    e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
    e:Spawn();
    e:Activate();
    return e;
end
 
function ENT:Initialize()
 
 
    self:SetNWInt("Health",self.StartHealth);
   
    self.WeaponLocations = {
        Left = self:GetPos()+self:GetForward()*125+self:GetUp()*75+self:GetRight()*-154,
        Right = self:GetPos()+self:GetForward()*125+self:GetUp()*75+self:GetRight()*160,
    }
    self.WeaponsTable = {};
    self.BoostSpeed = 2000;
    self.ForwardSpeed = 2000;
    self.UpSpeed = 600;
    self.AccelSpeed = 10;
    self.CanStandby = false;
    self.CanBack = false;
    self.CanRoll = false;
    self.CanStrafe = true;
    self.Cooldown = 2;
    self.CanShoot = false;
    self.Bullet = CreateBulletStructure(75,"unsc");
    self.FireDelay = 0.2;
    self.AlternateFire = true;
    self.FireGroup = {"Left","Right",};
    self.HasWings = true;
    self.WarpDestination = Vector(0,0,0);
   
    self.ExitModifier = {x=0,y=1585,z=10};
	--- These seats are mad bro --
    self.SeatPos = {
       
        {self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*-200,self:GetAngles()}, -- 1 --
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*-180,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*-160,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*-140,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*-120,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*-100,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*-80,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*-60,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*-40,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*-20,self:GetAngles()}, -- 10 --
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*0,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*20,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*40,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*60,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*80,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*100,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*10,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*140,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*160,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*100+self:GetForward()*180,self:GetAngles()}, -- 20 --
		
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*-200,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*-180,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*-160,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*-140,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*-120,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*-100,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*-80,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*-60,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*-40,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*-20,self:GetAngles()}, -- 30 --
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*0,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*20,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*40,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*60,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*80,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*100,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*10,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*140,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*160,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-100+self:GetForward()*180,self:GetAngles()}, -- 40 --
		
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*-200,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*-180,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*-160,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*-140,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*-120,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*-100,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*-80,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*-60,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*-40,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*-20,self:GetAngles()}, -- 50 --
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*0,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*20,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*40,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*60,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*80,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*100,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*10,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*140,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*160,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*70+self:GetForward()*180,self:GetAngles()}, -- 60 --
		
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*-200,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*-180,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*-160,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*-140,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*-120,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*-100,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*-80,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*-60,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*-40,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*-20,self:GetAngles()}, -- 70 --
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*0,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*20,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*40,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*60,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*80,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*100,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*10,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*140,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*160,self:GetAngles()},
		{self:GetPos()+self:GetUp()*500+self:GetRight()*-70+self:GetForward()*180,self:GetAngles()}, -- 80 --
		
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*-200,self:GetAngles()},
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*-180,self:GetAngles()},
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*-160,self:GetAngles()},
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*-140,self:GetAngles()},
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*-120,self:GetAngles()},
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*-100,self:GetAngles()},
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*-80,self:GetAngles()},
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*-60,self:GetAngles()},
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*-40,self:GetAngles()},
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*-20,self:GetAngles()}, -- 90 --
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*0,self:GetAngles()},
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*20,self:GetAngles()},
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*40,self:GetAngles()},
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*60,self:GetAngles()},
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*80,self:GetAngles()},
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*100,self:GetAngles()},
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*10,self:GetAngles()},
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*140,self:GetAngles()},
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*160,self:GetAngles()},
		{self:GetPos()+self:GetUp()*400+self:GetRight()*100+self:GetForward()*180,self:GetAngles()}, -- 100 --
   
    }
    self:SpawnSeats();
   
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
        e.IsCivilSeat = true;
        e.Civil = self;
 
        self.Seats[k] = e;
    end
 
end
 
function ENT:Enter(p)
	self.BaseClass.Enter(self,p);
	self:SetModel(self.ClosedModel);
end

function ENT:Exit(kill)
	self.BaseClass.Exit(self,kill);
	self:SetModel(self.WingsModel);
end

hook.Add("PlayerEnteredVehicle","CivilSeatEnter", function(p,v)
    if(IsValid(v) and IsValid(p)) then
        if(v.IsCivilSeat) then
            p:SetNetworkedEntity("Civil",v:GetParent());
        end
    end
end);
 
hook.Add("PlayerLeaveVehicle", "CivilSeatExit", function(p,v)
    if(IsValid(p) and IsValid(v)) then
        if(v.IsCivilSeat) then
            local e = v.Civil;
            if(IsValid(e)) then
                p:SetPos(e:GetPos() + e:GetRight()*e.ExitModifier.x + e:GetForward() * e.ExitModifier.y + e:GetUp() * e.ExitModifier.z);
            end
            p:SetNetworkedEntity("Civil",NULL);
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
 
end
 
if CLIENT then
   
    ENT.CanFPV = false;
    ENT.Sounds={
        Engine=Sound("ambient/atmosphere/ambience_base.wav"),
    }
   
    function ENT:Draw() self:DrawModel() end;
   
    function ENT:Think()
        self.BaseClass.Think(self);
        local p = LocalPlayer();
        local IsFlying = p:GetNWEntity("Civil");
        local Flying = self:GetNWBool("Flying".. self.Vehicle);
       
        if(Flying) then
            self.EnginePos = {
                self:GetPos()+self:GetForward()*-280+self:GetUp()*65+self:GetRight()*-80,
                self:GetPos()+self:GetForward()*-290+self:GetUp()*65+self:GetRight()*80,
            }
            self:FlightEffects();
        end
    end
   
    function ENT:FlightEffects()
        local normal = (self:GetForward() * -1):GetNormalized()
        local roll = math.Rand(-90,90)
        local p = LocalPlayer()    
        local FWD = self:GetForward();
        local id = self:EntIndex();
       
        local Engines = {
            self:GetPos()+self:GetForward()*-1180+self:GetUp()*365+self:GetRight()*-545,
			self:GetPos()+self:GetForward()*-1180+self:GetUp()*365+self:GetRight()*-595,
			self:GetPos()+self:GetForward()*-1180+self:GetUp()*275+self:GetRight()*-545,
			self:GetPos()+self:GetForward()*-1180+self:GetUp()*275+self:GetRight()*-595,
			self:GetPos()+self:GetForward()*-1180+self:GetUp()*420+self:GetRight()*-570,
			self:GetPos()+self:GetForward()*-1180+self:GetUp()*473+self:GetRight()*-570,
           
            self:GetPos()+self:GetForward()*-1180+self:GetUp()*365+self:GetRight()*545,
			self:GetPos()+self:GetForward()*-1180+self:GetUp()*365+self:GetRight()*595,
			self:GetPos()+self:GetForward()*-1180+self:GetUp()*275+self:GetRight()*545,
			self:GetPos()+self:GetForward()*-1180+self:GetUp()*275+self:GetRight()*595,
			self:GetPos()+self:GetForward()*-1180+self:GetUp()*420+self:GetRight()*570,
			self:GetPos()+self:GetForward()*-1180+self:GetUp()*473+self:GetRight()*570,

        }
        for k,v in pairs(Engines) do
            local blue = self.FXEmitter:Add("sprites/bluecore",v+FWD*1)
            blue:SetVelocity(normal)
            blue:SetDieTime(0.05)
            blue:SetStartAlpha(255)
            blue:SetEndAlpha(55)
            blue:SetStartSize(35)
            blue:SetEndSize(30)
            blue:SetRoll(roll)
            blue:SetColor(255,255,255)     
        end
   
    end
   
    local View = {}
	function CalcView()
		
		local p = LocalPlayer();
		local self = p:GetNetworkedEntity("Civil", NULL)
		if(IsValid(self)) then
			local fpvPos = self:GetPos()+self:GetUp()*20+self:GetForward()*350;
			View = SWVehicleView(self,2575,685,fpvPos,true);		
			return View;
		end
	end
    hook.Add("CalcView", "CivilView", CalcView)
   
    function CivilReticle()
       
        local p = LocalPlayer();
        local Flying = p:GetNWBool("FlyingCivil");
        local self = p:GetNWEntity("Civil");
        if(Flying and IsValid(self)) then
            HALO_HUD_DrawHull(2000);
            HALO_HUD_Compass(self);
            HALO_HUD_DrawSpeedometer();
        end
    end
    hook.Add("HUDPaint", "CivilReticle", CivilReticle)
 
end