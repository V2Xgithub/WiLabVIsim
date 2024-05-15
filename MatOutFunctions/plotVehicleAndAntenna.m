function plotVehicleAndAntenna(Vpolygon,Antenna)
%PLOTVEHICLEANDANTENNA Summary of this function goes here
%   Detailed explanation goes here
    figure();
    hold on;
    axis equal;
    plot(Vpolygon);

    % plot antenna Tx area
    scatter(Antenna(:,1), Antenna(:,2), 30, "r",'filled');
    dis = 1;
    for i = 1:size(Antenna,1)
        ang = Antenna(i,3):pi/1000:Antenna(i,4);
        p = dis*exp(1i*ang);
        TxArea = polyshape(Antenna(i,1)+[0, real(p)], Antenna(i,2)+[0, imag(p)]);
        plot(TxArea);
    end
end

