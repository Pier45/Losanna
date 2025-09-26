function draw_xregion(start, stop, y_limits, face_color, face_alpha)
    % x1, x2: scalar values (start and end of the region on x-axis)
    % y_limits: [y_min, y_max]
    % face_color: color spec (e.g., 'r', 'b', [0.5 0.5 0.5], etc.)

    for i=1:length(start)
        fill([start(i) stop(i) stop(i) start(i)], [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
            face_color, 'EdgeColor', 'none', 'FaceAlpha', face_alpha);
    end
end

