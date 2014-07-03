# 使用POE來進行non-blocking ping
# # 
# package OmsPing;
#
# BEGIN {
#     die "POE::Component::Client::Ping requires root privilege\n"
#             if $> and ( $^O ne 'VMS' );
#             }
#
#             use Mouse;
#             use Data::Dumper;
#             use DateTime;
#
#             has 'ips_list'    => (is => 'rw', isa => 'ArrayRef', required => 1);
#             has 'ips_dead'    => (is => 'ro', isa => 'ArrayRef');
#             has 'ips_latency' => (is => 'ro', isa => 'ArrayRef');
#
#
#             use Log::Log4perl::Appender::File;
#             #
#             my $logger = Log::Log4perl::Appender::File->new(
#                   filename  => '/home/op-submit/monitors/Log/pingqoc.log',
#                         mode      => 'append',
#                               autoflush => 1,
#                                     umask     => 0222,
#                                        );
#
#
#                                        my %dead;
#                                        my @latency;
#
#                                        use POE;
#                                        use POE::Component::Client::Ping;
#
#                                        sub poe_ping {
#
#                                            my $self = shift;
#                                                %dead    =  map { $_ => 1 } @{$self->ips_list};
#                                                    @latency = ();
#                                                        #------------------------------------------------------------------------------
#                                                            # The main loop.
#
#                                                                # Create a pinger component.  This will do the work of multiple
#                                                                    # concurrent pings.  It requires another session to interact with it.
#                                                                    #        Parallelism   => 150,
#                                                                        POE::Component::Client::Ping->spawn
#                                                                              ( Alias => 'pinger',     # The component's name will be "pinger".
#                                                                                      Parallelism   => 100,
#                                                                                              Timeout       => 1,    # The default ping timeout. in seconds
#                                                                                                      Retry         => 2,    # 不管成功與否都會連續ping3次
#                                                                                                          );
#
#                                                                                                              # Create a session that will use the pinger.  Its parameters match
#                                                                                                                  # event names with the functions that will handle them.
#
#                                                                                                                      POE::Session->create
#                                                                                                                            ( inline_states =>
#                                                                                                                                      { _start => \&ping_each_ip,    # Call client_start() to handle "_start".
#                                                                                                                                                  pong   => \&ip_got_pong,   # Call client_got_pong() to handle "pong".
#                                                                                                                                                              _stop  => \&ping_done 
#                                                                                                                                                                        },
#                                                                                                                                                                                  heap => { self => $self },
#                                                                                                                                                                                        );
#
#                                                                                                                                                                                            # Start POE's main loop.  It will only return when everything is done.
#
#                                                                                                                                                                                                $poe_kernel->run();
#
#                                                                                                                                                                                                    #close PINGS;
#
#                                                                                                                                                                                                    }
#
#                                                                                                                                                                                                    #------------------------------------------------------------------------------
#                                                                                                                                                                                                    # Event handlers.
#
#                                                                                                                                                                                                    sub ping_each_ip {
#
#                                                                                                                                                                                                        my ( $kernel, $session, $heap ) = @_[ KERNEL, SESSION, HEAP ];
#
#                                                                                                                                                                                                            my $self = $heap->{self};
#
#                                                                                                                                                                                                                foreach my $ip (@{$self->ips_list}) {
#                                                                                                                                                                                                                        $kernel->post( pinger => ping => pong => $ip );
#                                                                                                                                                                                                                            }
#                                                                                                                                                                                                                                #$logger->log( message => '-' x 20 . "\n");
#                                                                                                                                                                                                                                }
#
#                                                                                                                                                                                                                                # Handle a "pong" event (returned by the Ping component because we
#                                                                                                                                                                                                                                # asked it to).  Just display some information about the ping.
#
#                                                                                                                                                                                                                                sub ip_got_pong {
#                                                                                                                                                                                                                                    my ( $kernel, $session ) = @_[ KERNEL, SESSION ];
#
#                                                                                                                                                                                                                                        # The original request is returned as the first parameter.  It
#                                                                                                                                                                                                                                            # contains the address we wanted to ping, the total time to wait for
#                                                                                                                                                                                                                                                # a response, and the time the request was made.
#
#                                                                                                                                                                                                                                                    my $request_packet = $_[ARG0];
#                                                                                                                                                                                                                                                        my ($request_address, $request_timeout, $request_time) 
#                                                                                                                                                                                                                                                                = @{$request_packet};
#
#                                                                                                                                                                                                                                                                    # The response information is returned as the second parameter.  It
#                                                                                                                                                                                                                                                                        # contains the response address (which may be different from the
#                                                                                                                                                                                                                                                                            # request address), the ping's round-trip time, and the time the
#                                                                                                                                                                                                                                                                                # reply was received.
#
#                                                                                                                                                                                                                                                                                    my $response_packet = $_[ARG1];
#                                                                                                                                                                                                                                                                                        my ( $response_address, $roundtrip_time, $reply_time ) 
#                                                                                                                                                                                                                                                                                                = @{$response_packet};
#                                                                                                                                                                                                                                                                                                    
#                                                                                                                                                                                                                                                                                                        if (defined $roundtrip_time && $roundtrip_time >= 1.5) {
#                                                                                                                                                                                                                                                                                                                my $dt = DateTime->now( time_zone  => 'Asia/Taipei' );
#                                                                                                                                                                                                                                                                                                                        $logger->log( message => $dt->datetime() . ' ' . ($response_address || 'n/a') . ' ' . ($roundtrip_time || 'n/a') . ' ' . ($reply_time || 'n/a') . "\n");
#                                                                                                                                                                                                                                                                                                                            }
#
#                                                                                                                                                                                                                                                                                                                                # It is impossible to know ahead of time how many ICMP ping
#                                                                                                                                                                                                                                                                                                                                    # responses will arrive for a particular address, so the component
#                                                                                                                                                                                                                                                                                                                                        # always waits PING_TIMEOUT seconds.  An undefined response address
#                                                                                                                                                                                                                                                                                                                                            # signals that this waiting period has ended.
#
#                                                                                                                                                                                                                                                                                                                                                if ( defined $response_address ) {
#                                                                                                                                                                                                                                                                                                                                                        if ($roundtrip_time <= 1.5) {
#                                                                                                                                                                                                                                                                                                                                                                    delete $dead{ $request_address };
#                                                                                                                                                                                                                                                                                                                                                                            }
#                                                                                                                                                                                                                                                                                                                                                                                    else {
#                                                                                                                                                                                                                                                                                                                                                                                                push @latency, $request_address;
#                                                                                                                                                                                                                                                                                                                                                                                                        }
#                                                                                                                                                                                                                                                                                                                                                                                                            }
#                                                                                                                                                                                                                                                                                                                                                                                                                
#                                                                                                                                                                                                                                                                                                                                                                                                                }
#
#                                                                                                                                                                                                                                                                                                                                                                                                                sub ping_done {
#
#                                                                                                                                                                                                                                                                                                                                                                                                                    my $self = $_[ HEAP ]->{self};
#
#                                                                                                                                                                                                                                                                                                                                                                                                                        $self->{ips_dead}    = [keys %dead];
#                                                                                                                                                                                                                                                                                                                                                                                                                            $self->{ips_latency} = [@latency];
#
#                                                                                                                                                                                                                                                                                                                                                                                                                            }
#
#                                                                                                                                                                                                                                                                                                                                                                                                                            1;
#
