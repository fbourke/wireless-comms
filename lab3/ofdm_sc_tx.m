function Xhat = ofdm_sc_tx(Xtild)
    j = sqrt(-1);
    N = length(Xtild);

    sc = (round(rand(1, N))-.5)*2;

    packet = [sc sc sc];

    for i = 1:4
        htr = ifft((round(rand(1, N))-.5)*2);
        htrs(:,i) = pext(htr);
    end 

    packet = [packet reshape(htrs', 1, []) pext(ifft(Xtild))];
    % length(packet)

    packet_rx = nonflat_channel_timing_error(packet);
    pstart = packet_detect(packet_rx)
    % length(packet_rx)

    SCHMIDL_COX = packet_rx(pstart:pstart+N*3-1);
    % length(SCHMIDL_COX)

    idx = pstart+N*3;

    plen = N+N/4;

    for i = 1:4
        HTRS(:,i) = packet_rx(idx:idx+plen-1);
        idx = idx+plen;
    end
    % size(HTRS)

    DATA = packet_rx(idx:idx+plen-1);
    % length(DATA)

    figure(1)
    clf
    plot(real(packet))
    hold on
    plot(real(packet_rx))
    legend('Tx', 'Rx')

    diffs = SCHMIDL_COX(end-N+1:end)./SCHMIDL_COX(end-2*N+1:end-N);

    f_ests = log(diffs)./(j*N);
    f_est = abs(mean(f_ests))

    offset = exp(-j*f_est*N);

    % H estimation
    HTRS = HTRS.*offset;
    for i = 1:4
        Hunext = fft(unpext(HTRS(:,i)));
        Hunext = Hunext/length(Hunext);
        Hests(:,i) = Hunext./unpext(htrs(:,i));
    end

    Hest = mean(Hests);

    DATA = DATA.*offset;

    % Ytild = fft(ytild_f_est)/N;

    % ytild = ytild.*exp(-j*f_est);
    % Ytild = fft(ytild)/N;
end