function draw_xregion(x1, x2, y_limits, face_color, face_alpha)
    % x1, x2: scalar values (start and end of the region on x-axis)
    % y_limits: [y_min, y_max]
    % face_color: color spec (e.g., 'r', 'b', [0.5 0.5 0.5], etc.)

    fill([x1 x2 x2 x1], [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
        face_color, 'EdgeColor', 'none', 'FaceAlpha', face_alpha);
end

